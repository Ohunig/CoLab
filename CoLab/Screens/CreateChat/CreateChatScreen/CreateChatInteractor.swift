//
//  CreateChatInteractor.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import Foundation
import Combine

final class CreateChatInteractor: CreateChatBusinessLogic {
    private struct Constants {
        static let defaultAvatarURL = "avatar.jpg"
    }
    
    private enum AvatarSource: Equatable {
        case none
        case remote(String)
    }
    
    private let presenter: CreateChatPresentationLogic
    private let router: CreateChatRoutingLogic
    private let colorRepository: ColorStorageLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    private let chatService: ChatLogic
    
    private var isCreating = false
    private var memberIds: [String] = []
    private var membersById: [String: UserModel] = [:]
    private var avatarSourcesByMemberId: [String: AvatarSource] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var avatarCancellables: [String: AnyCancellable] = [:]
    
    // MARK: Lifecycle
    
    init(
        presenter: CreateChatPresentationLogic,
        router: CreateChatRoutingLogic,
        colorRepository: ColorStorageLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic,
        chatService: ChatLogic
    ) {
        self.presenter = presenter
        self.router = router
        self.colorRepository = colorRepository
        self.userService = userService
        self.avatarService = avatarService
        self.chatService = chatService
    }
    
    // MARK: Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                firstGradient: colorRepository.firstGradientColor,
                secondGradient: colorRepository.secondGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                tint: colorRepository.tintColor,
                textColor: colorRepository.mainTextColor
            )
        )
        presenter.presentCreatingState(
            Model.CreatingState.Response(isCreating: false)
        )
    }
    
    func loadDefaultAvatar() {
        avatarService.avatarDataPublisher(photoURL: Constants.defaultAvatarURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarData in
                self?.presenter.presentChatAvatar(
                    Model.ChatAvatar.Response(avatarData: avatarData)
                )
            }
            .store(in: &cancellables)
    }
    
    func loadCurrentUser() {
        userService.fetchCurrentUserOnce()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case let .failure(error) = completion else { return }
                    self?.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                },
                receiveValue: { [weak self] user in
                    self?.appendMember(user)
                }
            )
            .store(in: &cancellables)
    }
    
    func loadDataValidation(_ request: Model.Validation.Request) {
        let isValid = !trimmed(request.title).isEmpty
            && !trimmed(request.description).isEmpty
            && !memberIds.isEmpty
            && !isCreating
        
        presenter.presentDataValidation(
            Model.Validation.Response(isValid: isValid)
        )
    }
    
    func loadAddMemberScreen() {
        router.routeToSelectChatMember(
            excludedUserIds: memberIds
        ) { [weak self] user in
            self?.appendMember(user)
        }
    }
    
    func loadUserInfoScreen(userId: String) {
        router.routeToUserInfo(userId: userId)
    }
    
    func createChat(_ request: Model.CreateChat.Request) {
        guard !isCreating else { return }
        
        let title = trimmed(request.title)
        let description = trimmed(request.description)
        guard !title.isEmpty, !description.isEmpty, !memberIds.isEmpty else {
            presenter.presentDataValidation(
                Model.Validation.Response(isValid: false)
            )
            return
        }
        
        isCreating = true
        presenter.presentCreatingState(
            Model.CreatingState.Response(isCreating: true)
        )
        
        avatarURLPublisher(avatarData: request.avatarData)
            .flatMap { [weak self] avatarURL -> AnyPublisher<ChatModel, Error> in
                guard let self else {
                    return Fail(error: CancellationError()).eraseToAnyPublisher()
                }
                
                return self.chatService.createChat(
                    request: CreateChatRequest(
                        title: title,
                        description: description,
                        isPublic: request.isPublic,
                        memberIds: self.memberIds,
                        avatarURL: avatarURL
                    )
                )
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    if case let .failure(error) = completion {
                        self.isCreating = false
                        self.presenter.presentCreatingState(
                            Model.CreatingState.Response(isCreating: false)
                        )
                        self.presenter.presentError(
                            Model.ShowError.Response(error: error)
                        )
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.router.routeAfterChatCreated()
                }
            )
            .store(in: &cancellables)
    }
    
    func loadGoBack() {
        router.routeBack()
    }
    
    // MARK: Avatar
    
    private func avatarURLPublisher(
        avatarData: Data?
    ) -> AnyPublisher<String?, Error> {
        guard let avatarData else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return avatarService.uploadChatAvatarData(data: avatarData)
            .map { Optional($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: Members
    
    private func appendMember(_ user: UserModel) {
        guard !memberIds.contains(user.id) else { return }
        
        memberIds.append(user.id)
        membersById[user.id] = user
        presenter.presentMembers(
            Model.MembersList.Response(members: currentMembers())
        )
        syncMemberAvatar(for: user)
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
        // Не применяем устаревшую загрузку аватара, если данные пользователя уже поменялись
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
                username: user?.username ?? "...",
                avatarURL: user?.photoURL
            )
        }
    }
    
    // MARK: Factory methods
    
    private func avatarSource(for user: UserModel) -> AvatarSource {
        guard let photoURL = user.photoURL, !photoURL.isEmpty else {
            return .none
        }
        return .remote(photoURL)
    }
    
    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
