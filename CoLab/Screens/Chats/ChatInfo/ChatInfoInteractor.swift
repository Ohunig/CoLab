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
        static let noMembersText = "Участников нет"
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
    private var requestsCancellables = Set<AnyCancellable>()
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
        presentCurrentState()
        
        loadChatAvatarIfNeeded()
        loadMembers()
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
            .store(in: &requestsCancellables)
    }
    
    private func loadMembers() {
        // Каждый участник загружается отдельно, чтобы экран постепенно наполнялся именами
        guard !memberIds.isEmpty else { return }
        
        memberIds.forEach { memberId in
            userService.fetchUserOnce(id: memberId)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self else { return }
                        guard case let .failure(error) = completion else { return }
                        self.presentErrorIfNeeded(error)
                    },
                    receiveValue: { [weak self] user in
                        guard let self else { return }
                        self.membersById[user.id] = user
                        self.presentCurrentState()
                    }
                )
                .store(in: &requestsCancellables)
        }
    }
    
    private func presentCurrentState() {
        // Сохраняем исходный порядок участников таким же, каким он пришёл у чата
        let memberNames: [String]
        if memberIds.isEmpty {
            memberNames = [Constants.noMembersText]
        } else {
            memberNames = memberIds.map {
                membersById[$0]?.username ?? Constants.unknownUsername
            }
        }
        
        presenter.presentChatData(
            Model.GetChatData.Response(
                avatarData: currentAvatarData,
                isAvatarLoading: isAvatarLoading,
                title: chatTitle,
                memberNames: memberNames
            )
        )
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
