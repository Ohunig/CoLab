//
//  UserChatsInteractor.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation
import Combine

final class UserChatsInteractor: UserChatsBusinessLogic {
    
    private struct Constants {
        static let pageLimit = 10
    }
    
    // Структура для представления источника данных об аватаре
    private enum AvatarSource: Equatable {
        case none
        case remote(String)
    }
    
    // Шаг синхронизации загрузки аватаров с обновлениями чатов. Позволяет не обновлять аватары чатов у которых не поменялся url
    private struct AvatarSyncStep {
        static let empty = AvatarSyncStep(
            sourcesByChatId: [:],
            changedChats: []
        )
        
        let sourcesByChatId: [String: AvatarSource]
        let changedChats: [ChatModel]
    }
    
    private let presenter: UserChatsPresentationLogic
    
    private let colorRepository: ColorStorageLogic
    private let chatListService: UserChatListLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    
    private var canLoadMore = false
    private var isInitialLoadBound = false
    private var currentUserAvatarURL: String?
    
    private var pipelineCancellables = Set<AnyCancellable>()
    private var currentUserAvatarCancellable: AnyCancellable?
    private var desiredLiveLimit: Int = 0
    
    // MARK: Lifecycle
    
    init(
        presenter: UserChatsPresentationLogic,
        colorRepository: ColorStorageLogic,
        chatListService: UserChatListLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic
    ) {
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.chatListService = chatListService
        self.userService = userService
        self.avatarService = avatarService
    }
    
    deinit {
        pipelineCancellables.removeAll()
        currentUserAvatarCancellable?.cancel()
        userService.stopListeningChanges()
        chatListService.setLiveUpdatesLimit(0)
    }
    
    // MARK: - Use cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                textColor: colorRepository.mainTextColor
            )
        )
    }
    
    func listenCurrentUserAvatar() {
        userService.startListeningChanges()
        
        guard currentUserAvatarCancellable == nil else { return }
        
        currentUserAvatarCancellable = userService.currentUserDataPublisher()
            .flatMap { [weak self] user -> AnyPublisher<Data?, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                
                guard let photoURL = user.photoURL, !photoURL.isEmpty else {
                    self.currentUserAvatarURL = nil
                    return Just(nil).eraseToAnyPublisher()
                }
                
                guard photoURL != self.currentUserAvatarURL else {
                    return Empty().eraseToAnyPublisher()
                }
                
                self.currentUserAvatarURL = photoURL
                return self.avatarService.avatarDataPublisher(photoURL: photoURL)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarData in
                self?.presenter.presentCurrentUserAvatar(
                    Model.CurrentUserAvatar.Response(avatarData: avatarData)
                )
            }
    }
    
    func stopListeningCurrentUserAvatar() {
        currentUserAvatarCancellable?.cancel()
        currentUserAvatarCancellable = nil
        currentUserAvatarURL = nil
        userService.stopListeningChanges()
    }
    
    func loadInitialChats() {
        guard !isInitialLoadBound else { return }
        isInitialLoadBound = true
        
        canLoadMore = false
        desiredLiveLimit = Constants.pageLimit
        pipelineCancellables.removeAll()
        
        chatListService
            .userChatsUpdatesPublisher()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] result in
                // Обновление чатов как только пришли новые данные
                guard let self else { return }
                switch result {
                case let .success(chats):
                    // Если равны подгружаем дальше так как не можем точно сказать
                    self.canLoadMore = chats.count == self.desiredLiveLimit
                    self.presenter.presentChats(
                        Model.ChatsList.Response(
                            chats: chats
                        )
                    )
                case let .failure(error):
                    self.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                }
            })
            .compactMap { result -> [ChatModel]? in
                // Если пришёл failure то далее в поток ничего не уйдёт и аватары не будут обновляться
                guard case let .success(chats) = result else { return nil }
                return chats
            }
            .scan(AvatarSyncStep.empty) { [weak self] previousStep, chats in
                // Отдаёт в поток структуру со списком чатов, у которых обновился url аватара. Также в структуре словарь дающий url по id
                guard let self else { return .empty }
                return self.makeAvatarSyncStep(
                    for: chats,
                    previousSourcesByChatId: previousStep.sourcesByChatId
                )
            }
            .map { [weak self] step -> AnyPublisher<Model.AvatarUpdate.Response, Never> in
                // Отдаёт в поток паблишера, постепенно отдающего данные об аватарах
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.makeAvatarUpdatesPublisher(for: step.changedChats)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                // Приходит ответ Model.AvatarUpdate.Response -> просто отдаём на отображение в UI
                self?.presenter.presentAvatarUpdate(response)
            }
            .store(in: &pipelineCancellables)
        
        presenter.presentChats(
            Model.ChatsList.Response(
                chats: []
            )
        )
        
        chatListService.setLiveUpdatesLimit(desiredLiveLimit)
    }
    
    func loadNextPage() {
        // Избегаем бесконечной подгрузки страниц
        guard canLoadMore else { return }
        
        // Расширяем окно live-обновлений
        desiredLiveLimit += Constants.pageLimit
        chatListService.setLiveUpdatesLimit(desiredLiveLimit)
    }
    
    // MARK: Factory methods
    
    private func makeAvatarSyncStep(
        for chats: [ChatModel],
        previousSourcesByChatId: [String: AvatarSource]
    ) -> AvatarSyncStep {
        let nextSourcesByChatId = Dictionary(
            uniqueKeysWithValues: chats.map { chat in
                (chat.id, avatarSource(for: chat))
            }
        )
        // Чаты с изменившимся url аватара
        let changedChats = chats.filter { chat in
            previousSourcesByChatId[chat.id] != nextSourcesByChatId[chat.id]
        }
        return AvatarSyncStep(
            sourcesByChatId: nextSourcesByChatId,
            changedChats: changedChats
        )
    }
    
    // Создаёт паблишера, постепенно отдающего данные о аватарах переданных чатов
    private func makeAvatarUpdatesPublisher(
        for chats: [ChatModel]
    ) -> AnyPublisher<Model.AvatarUpdate.Response, Never> {
        let publishers = chats.map { chat -> AnyPublisher<Model.AvatarUpdate.Response, Never> in
            switch avatarSource(for: chat) {
            case .none:
                return Just(
                    Model.AvatarUpdate.Response(
                        chatId: chat.id,
                        avatarData: nil
                    )
                )
                .eraseToAnyPublisher()
            case let .remote(avatarURL):
                return avatarService
                    .avatarDataPublisher(photoURL: avatarURL)
                    .map { avatarData in
                        Model.AvatarUpdate.Response(
                            chatId: chat.id,
                            avatarData: avatarData
                        )
                    }
                    .eraseToAnyPublisher()
            }
        }
        
        guard publishers.isEmpty == false else {
            return Empty().eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
    
    private func avatarSource(for chat: ChatModel) -> AvatarSource {
        guard let avatarURL = chat.avatarURL, !avatarURL.isEmpty else {
            return .none
        }
        return .remote(avatarURL)
    }
}
