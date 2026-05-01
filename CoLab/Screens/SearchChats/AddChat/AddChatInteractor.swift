//
//  AddChatInteractor.swift
//  CoLab
//
//  Created by User on 01.05.2026.
//

import Foundation
import Combine

final class AddChatInteractor: AddChatBusinessLogic {
    
    private struct Constants {
        static let unknownTitle = "..."
        static let unknownUsername = "..."
    }
    
    private enum AvatarSource: Equatable {
        case none
        case remote(String)
    }
    
    private let chatId: String
    
    private let presenter: AddChatPresentationLogic
    private let colorRepository: ColorStorageLogic
    private let addChatService: AddChatLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    
    private var chatTitle = Constants.unknownTitle
    private var chatDescription: String?
    private var chatAvatarURL: String?
    private var memberIds: [String] = []
    
    private var currentAvatarData: Data?
    private var isAvatarLoading = false
    private var isAdding = false
    private var membersById: [String: UserModel] = [:]
    private var avatarSourcesByMemberId: [String: AvatarSource] = [:]
    private var pipelineCancellables = Set<AnyCancellable>()
    private var chatAvatarCancellable: AnyCancellable?
    private var memberCancellables: [String: AnyCancellable] = [:]
    private var avatarCancellables: [String: AnyCancellable] = [:]
    private var hasPresentedError = false
    
    // MARK: Lifecycle
    
    init(
        chatId: String,
        presenter: AddChatPresentationLogic,
        colorRepository: ColorStorageLogic,
        addChatService: AddChatLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic
    ) {
        self.chatId = chatId
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.addChatService = addChatService
        self.userService = userService
        self.avatarService = avatarService
    }
    
    // MARK: Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                tint: colorRepository.tintColor,
                textColor: colorRepository.mainTextColor,
                firstGradient: colorRepository.firstGradientColor,
                secondGradient: colorRepository.secondGradientColor
            )
        )
        
        presenter.presentAddButtonState(
            Model.AddButtonState.Response(
                isLoading: false,
                isAdded: false
            )
        )
        presentCurrentState()
        bindChat()
    }
    
    func addChat() {
        guard !isAdding else { return }
        
        guard let currentUserId = userService.currentUserId() else {
            presenter.presentError(
                Model.ShowError.Response(error: FetchUserChatsError.permissionDenied)
            )
            return
        }
        
        guard !memberIds.contains(currentUserId) else {
            presenter.presentAddButtonState(
                Model.AddButtonState.Response(
                    isLoading: false,
                    isAdded: true
                )
            )
            return
        }
        
        isAdding = true
        presenter.presentAddButtonState(
            Model.AddButtonState.Response(
                isLoading: true,
                isAdded: false
            )
        )
        
        addChatService.addCurrentUser(toChat: chatId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    if case let .failure(error) = completion {
                        self.isAdding = false
                        self.presenter.presentAddButtonState(
                            Model.AddButtonState.Response(
                                isLoading: false,
                                isAdded: self.isCurrentUserMember()
                            )
                        )
                        self.presenter.presentError(
                            Model.ShowError.Response(error: error)
                        )
                    }
                },
                receiveValue: { [weak self] in
                    self?.handleAddSuccess(currentUserId: currentUserId)
                }
            )
            .store(in: &pipelineCancellables)
    }
    
    // MARK: Chat updates
    
    private func bindChat() {
        addChatService.chatUpdatesPublisher(chatId: chatId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case let .failure(error):
                    self?.presentErrorIfNeeded(error)
                case let .success(chat):
                    self?.handleChatUpdate(chat)
                }
            }
            .store(in: &pipelineCancellables)
    }
    
    private func handleChatUpdate(_ chat: ChatModel) {
        let shouldUpdateAvatar = chatAvatarURL != chat.avatarURL
        
        chatTitle = chat.title
        chatDescription = chat.description
        syncMemberIds(chat.memberIds)
        
        presenter.presentAddButtonState(
            Model.AddButtonState.Response(
                isLoading: isAdding,
                isAdded: isCurrentUserMember()
            )
        )
        
        if shouldUpdateAvatar {
            updateChatAvatar(chat.avatarURL)
        } else {
            presentCurrentState()
        }
    }
    
    private func updateChatAvatar(_ nextAvatarURL: String?) {
        chatAvatarURL = nextAvatarURL
        chatAvatarCancellable?.cancel()
        currentAvatarData = nil
        
        // Если у чата нет аватара — просто скрываем shimmer и оставляем placeholder
        guard let nextAvatarURL, !nextAvatarURL.isEmpty else {
            isAvatarLoading = false
            presentCurrentState()
            return
        }
        
        isAvatarLoading = true
        presentCurrentState()
        
        chatAvatarCancellable = avatarService
            .avatarDataPublisher(photoURL: nextAvatarURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarData in
                guard let self,
                      self.chatAvatarURL == nextAvatarURL else {
                    return
                }
                
                self.currentAvatarData = avatarData
                self.isAvatarLoading = false
                self.presentCurrentState()
            }
    }
    
    // MARK: Helpers
    
    private func handleAddSuccess(currentUserId: String) {
        isAdding = false
        
        if !memberIds.contains(currentUserId) {
            memberIds.append(currentUserId)
        }
        
        presenter.presentMembers(
            Model.MembersList.Response(
                members: currentMembers()
            )
        )
        presenter.presentAddButtonState(
            Model.AddButtonState.Response(
                isLoading: false,
                isAdded: true
            )
        )
        bindMemberIfNeeded(currentUserId)
    }
    
    private func syncMemberIds(_ nextMemberIds: [String]) {
        let previousIds = Set(memberIds)
        let nextIds = Set(nextMemberIds)
        memberIds = nextMemberIds
        
        previousIds.subtracting(nextIds).forEach { memberId in
            memberCancellables[memberId]?.cancel()
            memberCancellables.removeValue(forKey: memberId)
            avatarCancellables[memberId]?.cancel()
            avatarCancellables.removeValue(forKey: memberId)
            avatarSourcesByMemberId.removeValue(forKey: memberId)
            membersById.removeValue(forKey: memberId)
        }
        
        presenter.presentMembers(
            Model.MembersList.Response(
                members: currentMembers()
            )
        )
        bindMembers()
    }
    
    private func bindMembers() {
        memberIds.forEach { bindMemberIfNeeded($0) }
    }
    
    private func bindMemberIfNeeded(_ memberId: String) {
        guard memberCancellables[memberId] == nil else { return }
        
        let cancellable = userService
            .userUpdatesPublisher(id: memberId)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.userService.startListeningUser(id: memberId)
                },
                receiveCancel: { [weak self] in
                    self?.userService.stopListeningUser(id: memberId)
                }
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.handleMemberUpdateResult(result)
            }
        
        memberCancellables[memberId] = cancellable
    }
    
    private func presentCurrentState() {
        presenter.presentChatData(
            Model.GetChatData.Response(
                avatarData: currentAvatarData,
                isAvatarLoading: isAvatarLoading,
                title: chatTitle,
                description: chatDescription
            )
        )
    }
    
    private func isCurrentUserMember() -> Bool {
        guard let currentUserId = userService.currentUserId() else { return false }
        return memberIds.contains(currentUserId)
    }
    
    // MARK: Member updates
    
    private func handleMemberUpdateResult(
        _ result: Result<UserModel, FetchUserError>
    ) {
        switch result {
        case let .failure(error):
            presentErrorIfNeeded(error)
        case let .success(user):
            membersById[user.id] = user
            presenter.presentMembers(
                Model.MembersList.Response(
                    members: currentMembers()
                )
            )
            syncMemberAvatar(for: user)
        }
    }
    
    private func syncMemberAvatar(for user: UserModel) {
        let nextSource = avatarSource(for: user)
        guard avatarSourcesByMemberId[user.id] != nextSource else { return }
        
        avatarSourcesByMemberId[user.id] = nextSource
        avatarCancellables[user.id]?.cancel()
        
        switch nextSource {
        case .none:
            presenter.presentAvatarUpdate(
                Model.AvatarUpdate.Response(
                    memberId: user.id,
                    avatarURL: "",
                    avatarData: nil
                )
            )
        case let .remote(photoURL):
            avatarCancellables[user.id] = avatarService
                .avatarDataPublisher(photoURL: photoURL)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] avatarData in
                    self?.handleMemberAvatarUpdate(
                        Model.AvatarUpdate.Response(
                            memberId: user.id,
                            avatarURL: photoURL,
                            avatarData: avatarData
                        )
                    )
                }
        }
    }
    
    private func handleMemberAvatarUpdate(
        _ response: Model.AvatarUpdate.Response
    ) {
        guard membersById[response.memberId]?.photoURL == response.avatarURL else {
            return
        }
        
        presenter.presentAvatarUpdate(response)
    }
    
    private func currentMembers() -> [Model.MembersList.Member] {
        memberIds.map { memberId in
            let user = membersById[memberId]
            return Model.MembersList.Member(
                id: memberId,
                username: user?.username ?? Constants.unknownUsername,
                avatarURL: user?.photoURL
            )
        }
    }
    
    private func avatarSource(for user: UserModel) -> AvatarSource {
        guard let photoURL = user.photoURL, !photoURL.isEmpty else {
            return .none
        }
        return .remote(photoURL)
    }
    
    private func presentErrorIfNeeded(_ error: Error) {
        // Не дублируем один и тот же alert на частичных ошибках загрузки участников
        guard !hasPresentedError else { return }
        hasPresentedError = true
        presenter.presentError(
            Model.ShowError.Response(error: error)
        )
    }
}
