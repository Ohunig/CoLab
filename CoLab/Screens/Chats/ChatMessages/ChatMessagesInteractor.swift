//
//  ChatMessagesInteractor.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation
import Combine

final class ChatMessagesInteractor: ChatMessagesBusinessLogic {
    
    private struct Constants {
        static let pageLimit = 30
        static let senderUpdateDebounce: TimeInterval = 0.12
        static let secondaryTextAlpha: CGFloat = 0.72
    }
    
    private struct SenderState {
        var username: String?
        var photoURL: String?
        var avatarData: Data?
    }
    
    private let chatId: String
    private let chatTitle: String
    private let chatAvatarURL: String?
    private let memberIds: [String]
    private var currentUserId: String?
    
    private let presenter: ChatMessagesPresentationLogic
    private let router: ChatsRoutingLogic
    private let colorRepository: ColorStorageLogic
    // Сервисы
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    private let messagesService: ChatMessagesLogic
    
    private var orderedMessages: [ChatMessageModel] = []
    private var oldestLoadedMessage: ChatMessageModel?
    private var newestLoadedMessage: ChatMessageModel?
    private var latestKnownLastMessageDate: Date?
    
    private var hasMorePreviousMessages = true
    private var isInitialLoading = false
    private var isLoadingPreviousMessages = false
    private var isLoadingNewMessages = false
    
    private var requestsCancellables = Set<AnyCancellable>()
    private var chatUpdatesCancellable: AnyCancellable?
    private var chatAvatarCancellable: AnyCancellable?
    private var senderUserCancellables: [String: AnyCancellable] = [:]
    private var senderAvatarCancellables: [String: AnyCancellable] = [:]
    private var senderStatesById: [String: SenderState] = [:]
    private var pendingMessagesUpdateWorkItem: DispatchWorkItem?
    
    // MARK: Lifecycle
    
    init(
        chatId: String,
        chatTitle: String,
        chatAvatarURL: String?,
        memberIds: [String],
        presenter: ChatMessagesPresentationLogic,
        router: ChatsRoutingLogic,
        colorRepository: ColorStorageLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic,
        messagesService: ChatMessagesLogic
    ) {
        self.chatId = chatId
        self.chatTitle = chatTitle
        self.chatAvatarURL = chatAvatarURL
        self.memberIds = memberIds
        self.presenter = presenter
        self.router = router
        self.colorRepository = colorRepository
        self.userService = userService
        self.avatarService = avatarService
        self.messagesService = messagesService
    }
    
    deinit {
        stopUpdates()
        stopListeningChatAvatar()
        requestsCancellables.removeAll()
        senderUserCancellables.values.forEach { $0.cancel() }
        senderAvatarCancellables.values.forEach { $0.cancel() }
        Set(senderUserCancellables.keys).forEach { userService.stopListeningUser(id: $0) }
        pendingMessagesUpdateWorkItem?.cancel()
    }
    
    // MARK: Use cases
    
    func loadStart() {
        currentUserId = userService.currentUserId()
        
        let baseColor = colorRepository.elementsBaseColor
        let textColor = colorRepository.mainTextColor
        let secondaryTextColor = ColorModel(
            red: textColor.red,
            green: textColor.green,
            blue: textColor.blue,
            alpha: Constants.secondaryTextAlpha
        )
        
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                incomingBase: baseColor,
                incomingBorder: baseColor,
                outgoingGradientStart: colorRepository.firstGradientColor,
                outgoingGradientEnd: colorRepository.secondGradientColor,
                incomingTextColor: textColor,
                outgoingTextColor: textColor,
                senderNameColor: secondaryTextColor
            )
        )
    }
    
    // Загружаем только последние сообщения. Старые подтягиваются позже через пагинацию вверх.
    func loadInitialMessages() {
        guard orderedMessages.isEmpty else { return }
        guard !isInitialLoading else { return }
        
        isInitialLoading = true
        
        messagesService.fetchLatestMessages(
            chatId: chatId,
            limit: Constants.pageLimit
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isInitialLoading = false
                
                if case let .failure(error) = completion {
                    self.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                }
                
                self.fetchNewMessagesIfNeeded()
            },
            receiveValue: { [weak self] messages in
                guard let self else { return }
                
                self.orderedMessages = messages
                self.oldestLoadedMessage = messages.first
                self.newestLoadedMessage = messages.last
                self.hasMorePreviousMessages = messages.count == Constants.pageLimit
                
                self.presenter.presentMessages(
                    Model.MessagesList.Response(
                        messages: messages,
                        currentUserId: self.currentUserId,
                        senderDataById: self.senderDataById()
                    )
                )
                
                // sender data догружаются отдельно и позже дают точечный update списка
                self.syncIncomingSenderData(for: messages)
            }
        )
        .store(in: &requestsCancellables)
    }
    
    // Слушаем не сами сообщения, а только lastMessageDate у чата.
    // Это дешевле, а новые сообщения потом добираются отдельным запросом.
    func startUpdates() {
        guard chatUpdatesCancellable == nil else { return }
        
        messagesService.startListeningChat(chatId: chatId)
        chatUpdatesCancellable = messagesService.chatLastMessageDatePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                
                switch result {
                case let .failure(error):
                    self.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                case let .success(lastMessageDate):
                    self.latestKnownLastMessageDate = lastMessageDate
                    self.fetchNewMessagesIfNeeded()
                }
            }
    }
    
    func listenChatAvatar() {
        guard chatAvatarCancellable == nil else { return }
        
        guard let chatAvatarURL, !chatAvatarURL.isEmpty else {
            presenter.presentChatAvatar(
                Model.ChatAvatar.Response(avatarData: nil)
            )
            return
        }
        
        chatAvatarCancellable = avatarService.avatarDataPublisher(photoURL: chatAvatarURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarData in
                self?.presenter.presentChatAvatar(
                    Model.ChatAvatar.Response(avatarData: avatarData)
                )
            }
    }
    
    func loadChatInfoScreen() {
        router.routeToChatInfo(
            chatTitle: chatTitle,
            chatAvatarURL: chatAvatarURL,
            memberIds: memberIds
        )
    }
    
    func stopUpdates() {
        chatUpdatesCancellable?.cancel()
        chatUpdatesCancellable = nil
        messagesService.stopListeningChat()
    }
    
    func stopListeningChatAvatar() {
        chatAvatarCancellable?.cancel()
        chatAvatarCancellable = nil
    }
    
    func loadPreviousMessages() {
        guard hasMorePreviousMessages else { return }
        guard !isLoadingPreviousMessages else { return }
        guard let oldestLoadedMessage else { return }
        
        isLoadingPreviousMessages = true
        
        messagesService.fetchMessages(
            before: oldestLoadedMessage,
            chatId: chatId,
            limit: Constants.pageLimit
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isLoadingPreviousMessages = false
                
                if case let .failure(error) = completion {
                    self.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                }
            },
            receiveValue: { [weak self] messages in
                guard let self else { return }
                
                let olderMessages = self.uniqueMessages(
                    from: messages,
                    excluding: self.orderedMessages
                )
                self.hasMorePreviousMessages = messages.count == Constants.pageLimit
                
                guard !olderMessages.isEmpty else { return }
                
                // Храним сообщения в естественном порядке old -> new.
                // Поэтому старую страницу просто вставляем в начало массива.
                self.orderedMessages.insert(contentsOf: olderMessages, at: 0)
                self.oldestLoadedMessage = self.orderedMessages.first
                
                self.presenter.presentMessages(
                    Model.MessagesList.Response(
                        messages: self.orderedMessages,
                        currentUserId: self.currentUserId,
                        senderDataById: self.senderDataById()
                    )
                )
                
                self.syncIncomingSenderData(for: self.orderedMessages)
            }
        )
        .store(in: &requestsCancellables)
    }
    
    func sendMessage(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        messagesService.sendMessage(
            text: trimmedText,
            chatId: chatId
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                guard case let .failure(error) = completion else { return }
                
                self.presenter.presentError(
                    Model.ShowError.Response(error: error)
                )
            },
            receiveValue: { [weak self] message in
                guard let self else { return }
                guard !self.orderedMessages.contains(where: { $0.id == message.id }) else {
                    return
                }
                
                self.latestKnownLastMessageDate = message.createdAt
                self.orderedMessages.append(message)
                self.newestLoadedMessage = self.orderedMessages.last
                self.oldestLoadedMessage = self.orderedMessages.first
                
                self.presenter.presentMessages(
                    Model.MessagesList.Response(
                        messages: self.orderedMessages,
                        currentUserId: self.currentUserId,
                        senderDataById: self.senderDataById()
                    )
                )
            }
        )
        .store(in: &requestsCancellables)
    }
    
    // MARK: Messages
    
    // Если чат сообщил что в нём была активность, пробуем добрать всё что новее уже загруженного последнего сообщения.
    private func fetchNewMessagesIfNeeded() {
        guard !isInitialLoading else { return }
        guard !isLoadingNewMessages else { return }
        guard latestKnownLastMessageDate != nil else { return }
        
        guard let newestLoadedMessage else {
            if orderedMessages.isEmpty {
                loadInitialMessages()
            }
            return
        }

        isLoadingNewMessages = true
        
        messagesService.fetchMessages(
            after: newestLoadedMessage,
            chatId: chatId
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isLoadingNewMessages = false
                
                if case let .failure(error) = completion {
                    self.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                }
                // Пытаемся загружать заново
                self.fetchNewMessagesIfNeeded()
            },
            receiveValue: { [weak self] messages in
                guard let self else { return }
                
                let newMessages = self.uniqueMessages(
                    from: messages,
                    excluding: self.orderedMessages
                )
                guard !newMessages.isEmpty else { return }
                
                // Новые сообщения всегда дописываются в конец так как массив хранится old -> new
                self.orderedMessages.append(contentsOf: newMessages)
                self.newestLoadedMessage = self.orderedMessages.last
                self.oldestLoadedMessage = self.orderedMessages.first
                
                self.presenter.presentMessages(
                    Model.MessagesList.Response(
                        messages: self.orderedMessages,
                        currentUserId: self.currentUserId,
                        senderDataById: self.senderDataById()
                    )
                )
                
                self.syncIncomingSenderData(for: self.orderedMessages)
            }
        )
        .store(in: &requestsCancellables)
    }
    
    private func uniqueMessages(
        from messages: [ChatMessageModel],
        excluding existingMessages: [ChatMessageModel]
    ) -> [ChatMessageModel] {
        let existingIds = Set(existingMessages.map(\.id))
        return messages.filter { !existingIds.contains($0.id) }
    }
    
    // MARK: Sender data
    
    private func syncIncomingSenderData(for messages: [ChatMessageModel]) {
        let senderIds = Set(
            messages.compactMap { message -> String? in
                guard message.senderId != currentUserId else { return nil }
                return message.senderId
            }
        )
        
        // Для каждого входящего senderId отдельно подтягиваем username и аватар
        senderIds.forEach { ensureSenderDataLoading(for: $0) }
    }
    
    private func ensureSenderDataLoading(for senderId: String) {
        if senderUserCancellables[senderId] == nil {
            startListeningSenderUser(senderId: senderId)
        }
        
        guard let photoURL = senderStatesById[senderId]?.photoURL,
              !photoURL.isEmpty,
              senderStatesById[senderId]?.avatarData == nil,
              senderAvatarCancellables[senderId] == nil else {
            return
        }
        
        loadSenderAvatar(senderId: senderId, photoURL: photoURL)
    }
    
    private func startListeningSenderUser(senderId: String) {
        userService.startListeningUser(id: senderId)
        
        senderUserCancellables[senderId] = userService.userUpdatesPublisher(id: senderId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                
                switch result {
                case let .failure(error):
                    self.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                case let .success(user):
                    let previousPhotoURL = self.senderStatesById[senderId]?.photoURL
                    var state = self.senderStatesById[senderId] ?? SenderState()
                    state.username = user.username
                    state.photoURL = user.photoURL
                    if previousPhotoURL != user.photoURL {
                        self.senderAvatarCancellables[senderId]?.cancel()
                        self.senderAvatarCancellables.removeValue(forKey: senderId)
                        state.avatarData = nil
                    }
                    self.senderStatesById[senderId] = state
                    
                    // Не шлём presenter update на каждое поле сразу.
                    self.scheduleMessagesUpdate()
                    
                    guard let photoURL = user.photoURL,
                          !photoURL.isEmpty else { return }
                    
                    self.loadSenderAvatar(senderId: senderId, photoURL: photoURL)
                }
            }
    }
    
    private func loadSenderAvatar(senderId: String, photoURL: String) {
        senderAvatarCancellables[senderId]?.cancel()
        senderAvatarCancellables[senderId] = avatarService.avatarDataPublisher(photoURL: photoURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarData in
                guard let self else { return }
                self.senderAvatarCancellables.removeValue(forKey: senderId)
                
                guard self.senderStatesById[senderId]?.photoURL == photoURL else { return }
                guard self.senderStatesById[senderId]?.avatarData != avatarData else { return }
                
                self.senderStatesById[senderId]?.avatarData = avatarData
                self.scheduleMessagesUpdate()
            }
    }
    
    // MARK: Sender updates
    
    private func scheduleMessagesUpdate() {
        guard !orderedMessages.isEmpty else { return }
        
        // sender data могут прилететь почти одновременно
        // Склеиваем их в один update чтобы коллекция не дёргалась
        pendingMessagesUpdateWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.presentMessagesUpdate()
        }
        pendingMessagesUpdateWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.senderUpdateDebounce,
            execute: workItem
        )
    }

    private func presentMessagesUpdate() {
        guard !orderedMessages.isEmpty else { return }
        pendingMessagesUpdateWorkItem = nil
        
        // Здесь сами сообщения не меняются.
        // Меняются только display данные вроде username и avatarData.
        presenter.presentMessages(
            Model.MessagesList.Response(
                messages: orderedMessages,
                currentUserId: currentUserId,
                senderDataById: senderDataById()
            )
        )
    }
    
    // Presenter получает sender data сразу словарём чтобы потом быстро собирать item'ы по senderId
    private func senderDataById() -> [String: Model.MessagesList.SenderData] {
        senderStatesById.mapValues { state in
            Model.MessagesList.SenderData(
                username: state.username,
                avatarData: state.avatarData
            )
        }
    }
}
