//
//  SearchChatsListInteractor.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import Foundation
import Combine

final class SearchChatsListInteractor: SearchChatsListBusinessLogic {
    private struct Constants {
        static let pageLimit = 10
    }
    
    private enum AvatarSource: Equatable {
        case none
        case remote(String)
    }
    
    private let presenter: SearchChatsListPresentationLogic
    private let colorRepository: ColorStorageLogic
    private let router: SearchChatsRoutingLogic
    
    private let chatListService: SearchChatsListLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    
    private var orderedChats: [ChatModel] = []
    private var canLoadMore = false
    private var isLoadingPage = false
    private var currentUserAvatarURL: String?
    private var avatarSourcesByChatId: [String: AvatarSource] = [:]
    
    private var pageCancellables = Set<AnyCancellable>()
    private var avatarCancellables: [String: AnyCancellable] = [:]
    private var currentUserAvatarCancellable: AnyCancellable?
    
    // MARK: Lifecycle
    
    init(
        presenter: SearchChatsListPresentationLogic,
        colorRepository: ColorStorageLogic,
        chatListService: SearchChatsListLogic,
        router: SearchChatsRoutingLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic
    ) {
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.chatListService = chatListService
        self.router = router
        self.userService = userService
        self.avatarService = avatarService
    }
    
    deinit {
        pageCancellables.removeAll()
        avatarCancellables.values.forEach { $0.cancel() }
        currentUserAvatarCancellable?.cancel()
        userService.stopListeningChanges()
    }
    
    // MARK: Use cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                textColor: colorRepository.mainTextColor,
                startGradient: colorRepository.firstGradientColor,
                endGradient: colorRepository.secondGradientColor
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
        guard orderedChats.isEmpty else { return }
        guard !isLoadingPage else { return }
        
        canLoadMore = false
        chatListService.reset()
        avatarSourcesByChatId.removeAll()
        avatarCancellables.values.forEach { $0.cancel() }
        avatarCancellables.removeAll()
        
        loadPage(
            chatListService.fetchFirstPage(limit: Constants.pageLimit),
            replacingCurrentChats: true
        )
    }
    
    func loadNextPage() {
        guard canLoadMore else { return }
        guard !isLoadingPage else { return }
        
        loadPage(
            chatListService.fetchNextPage(limit: Constants.pageLimit),
            replacingCurrentChats: false
        )
    }
    
    func loadChatInfoScreen(
        chatTitle: String,
        chatDescription: String?,
        chatAvatarURL: String?,
        memberIds: [String]
    ) {
        router.routeToChatInfo(
            chatTitle: chatTitle,
            chatDescription: chatDescription,
            chatAvatarURL: chatAvatarURL,
            memberIds: memberIds
        )
    }
    
    // MARK: Helpers
    
    private func loadPage(
        _ publisher: AnyPublisher<SearchChatsPage, FetchUserChatsError>,
        replacingCurrentChats: Bool
    ) {
        isLoadingPage = true
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoadingPage = false
                    
                    if case let .failure(error) = completion {
                        self.presenter.presentError(
                            Model.ShowError.Response(error: error)
                        )
                    }
                },
                receiveValue: { [weak self] page in
                    self?.handleLoadedPage(
                        page,
                        replacingCurrentChats: replacingCurrentChats
                    )
                }
            )
            .store(in: &pageCancellables)
    }
    
    private func handleLoadedPage(
        _ page: SearchChatsPage,
        replacingCurrentChats: Bool
    ) {
        canLoadMore = page.hasMore
        
        if replacingCurrentChats {
            orderedChats = page.chats
        } else {
            let existingIds = Set(orderedChats.map(\.id))
            orderedChats.append(
                contentsOf: page.chats.filter { !existingIds.contains($0.id) }
            )
        }
        
        presenter.presentChats(
            Model.ChatsList.Response(chats: orderedChats)
        )
        
        syncChatAvatars(for: page.chats)
    }
    
    private func syncChatAvatars(for chats: [ChatModel]) {
        chats.forEach { chat in
            let nextSource = avatarSource(for: chat)
            guard avatarSourcesByChatId[chat.id] != nextSource else { return }
            
            avatarSourcesByChatId[chat.id] = nextSource
            avatarCancellables[chat.id]?.cancel()
            
            switch nextSource {
            case .none:
                presenter.presentAvatarUpdate(
                    Model.AvatarUpdate.Response(
                        chatId: chat.id,
                        avatarData: nil
                    )
                )
            case let .remote(avatarURL):
                avatarCancellables[chat.id] = avatarService
                    .avatarDataPublisher(photoURL: avatarURL)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] avatarData in
                        self?.presenter.presentAvatarUpdate(
                            Model.AvatarUpdate.Response(
                                chatId: chat.id,
                                avatarData: avatarData
                            )
                        )
                    }
            }
        }
    }
    
    private func avatarSource(for chat: ChatModel) -> AvatarSource {
        guard let avatarURL = chat.avatarURL, !avatarURL.isEmpty else {
            return .none
        }
        return .remote(avatarURL)
    }
}
