//
//  ChatInfoInteractor.swift
//  CoLab
//
//  Created by User on 14.04.2026.
//

import Foundation
import Combine

final class ChatInfoInteractor: ChatInfoBusinessLogic {
    
    private struct Constants {
        static let unknownUsername = "..."
    }
    
    private enum AvatarSource: Equatable {
        case none
        case remote(String)
    }
    
    private struct AvatarSyncStep {
        static let empty = AvatarSyncStep(
            sourcesByMemberId: [:],
            changedUsers: []
        )
        
        let sourcesByMemberId: [String: AvatarSource]
        let changedUsers: [UserModel]
    }
    
    private let chatTitle: String
    private let chatAvatarURL: String?
    private let memberIds: [String]
    
    private let presenter: ChatInfoPresentationLogic
    private let colorRepository: ColorStorageLogic
    private let userService: UserServiceLogic
    private let avatarService: AvatarServiceLogic
    
    private var currentAvatarData: Data?
    private var isAvatarLoading = false
    private var membersById: [String: UserModel] = [:]
    private var pipelineCancellables = Set<AnyCancellable>()
    private var hasPresentedError = false
    
    // MARK: Lifecycle
    
    init(
        chatTitle: String,
        chatAvatarURL: String?,
        memberIds: [String],
        presenter: ChatInfoPresentationLogic,
        colorRepository: ColorStorageLogic,
        userService: UserServiceLogic,
        avatarService: AvatarServiceLogic
    ) {
        self.chatTitle = chatTitle
        self.chatAvatarURL = chatAvatarURL
        self.memberIds = memberIds
        self.presenter = presenter
        self.colorRepository = colorRepository
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
                textColor: colorRepository.mainTextColor
            )
        )
        
        isAvatarLoading = !(chatAvatarURL?.isEmpty ?? true)
        presenter.presentMembers(
            Model.MembersList.Response(
                members: currentMembers()
            )
        )
        presentCurrentState()
        
        loadChatAvatarIfNeeded()
        bindMembers()
    }
    
    private func loadChatAvatarIfNeeded() {
        // Если у чата нет аватара — просто скрываем shimmer и оставляем placeholder
        guard let chatAvatarURL, !chatAvatarURL.isEmpty else {
            isAvatarLoading = false
            presentCurrentState()
            return
        }
        
        avatarService.avatarDataPublisher(photoURL: chatAvatarURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarData in
                guard let self else { return }
                self.currentAvatarData = avatarData
                self.isAvatarLoading = false
                self.presentCurrentState()
            }
            .store(in: &pipelineCancellables)
    }
    
    private func bindMembers() {
        guard !memberIds.isEmpty else { return }
        
        makeMembersPublisher()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] result in
                self?.handleMemberUpdateResult(result)
            })
            .compactMap { result -> UserModel? in
                guard case let .success(user) = result else { return nil }
                return user
            }
            .scan(AvatarSyncStep.empty) { [weak self] previousStep, user in
                guard let self else { return .empty }
                return self.makeAvatarSyncStep(
                    for: user,
                    previousSourcesByMemberId: previousStep.sourcesByMemberId
                )
            }
            .map { [weak self] step -> AnyPublisher<Model.AvatarUpdate.Response, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.makeAvatarUpdatesPublisher(for: step.changedUsers)
            }
            .flatMap(maxPublishers: .unlimited) { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.handleMemberAvatarUpdate(response)
            }
            .store(in: &pipelineCancellables)
    }
    
    private func presentCurrentState() {
        presenter.presentChatData(
            Model.GetChatData.Response(
                avatarData: currentAvatarData,
                isAvatarLoading: isAvatarLoading,
                title: chatTitle
            )
        )
    }
    
    // MARK: Factory methods
    
    private func makeMembersPublisher()
        -> AnyPublisher<Result<UserModel, FetchUserError>, Never> {
        let publishers = memberIds.map { [weak self] memberId in
            self?.userService
                .userUpdatesPublisher(id: memberId)
                .handleEvents(
                    receiveSubscription: { [weak self] _ in
                        self?.userService.startListeningUser(id: memberId)
                    },
                    receiveCancel: { [weak self] in
                        self?.userService.stopListeningUser(id: memberId)
                    }
                )
                .eraseToAnyPublisher()
            ?? Empty().eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
    
    private func makeAvatarUpdatesPublisher(
        for users: [UserModel]
    ) -> AnyPublisher<Model.AvatarUpdate.Response, Never> {
        let publishers = users.compactMap { user -> AnyPublisher<Model.AvatarUpdate.Response, Never>? in
            guard let photoURL = user.photoURL, !photoURL.isEmpty else {
                return nil
            }
            
            return avatarService.avatarDataPublisher(photoURL: photoURL)
                .map { avatarData in
                    Model.AvatarUpdate.Response(
                        memberId: user.id,
                        avatarURL: photoURL,
                        avatarData: avatarData
                    )
                }
                .eraseToAnyPublisher()
        }
        
        guard !publishers.isEmpty else {
            return Empty().eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
    
    private func makeAvatarSyncStep(
        for user: UserModel,
        previousSourcesByMemberId: [String: AvatarSource]
    ) -> AvatarSyncStep {
        let nextSource = avatarSource(for: user)
        var nextSourcesByMemberId = previousSourcesByMemberId
        nextSourcesByMemberId[user.id] = nextSource
        
        let changedUsers: [UserModel]
        if previousSourcesByMemberId[user.id] != nextSource {
            changedUsers = [user]
        } else {
            changedUsers = []
        }
        
        return AvatarSyncStep(
            sourcesByMemberId: nextSourcesByMemberId,
            changedUsers: changedUsers
        )
    }
    
    private func avatarSource(for user: UserModel) -> AvatarSource {
        guard let photoURL = user.photoURL, !photoURL.isEmpty else {
            return .none
        }
        return .remote(photoURL)
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
    
    private func presentErrorIfNeeded(_ error: Error) {
        // Не дублируем один и тот же alert на частичных ошибках загрузки участников
        guard !hasPresentedError else { return }
        hasPresentedError = true
        presenter.presentError(
            Model.ShowError.Response(error: error)
        )
    }
}
