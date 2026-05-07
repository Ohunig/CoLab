//
//  AddChatMemberPresenter.swift
//  CoLab
//
//  Created by User on 07.05.2026.
//

import Foundation

final class AddChatMemberPresenter: AddChatMemberPresentationLogic {
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
        static let defaultBaseColor = (hex: "#FFFFFF", a: CGFloat(0.35))
        static let defaultTintColor = (hex: "#FFFFFF", a: CGFloat(1))
        static let defaultTextColor = (hex: "#FFFFFF", a: CGFloat(1))
    }
    
    weak var controller: AddChatMemberDisplayLogic?
    
    private var orderedIds: [String] = []
    private var itemsById: [String: Model.FriendsList.ViewModel.FriendCell] = [:]
    
    private var cellBaseColor = Constants.defaultBaseColor
    private var cellTintColor = Constants.defaultTintColor
    private var cellTextColor = Constants.defaultTextColor
    
    func presentStart(_ response: Model.Start.Response) {
        cellBaseColor = (
            hex: response.elementsBase.hex,
            a: response.elementsBase.alpha
        )
        cellTintColor = (
            hex: response.tint.hex,
            a: response.tint.alpha
        )
        cellTextColor = (
            hex: response.textColor.hex,
            a: response.textColor.alpha
        )
        
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (
                    hex: response.bgGradient.hex,
                    a: response.bgGradient.alpha
                ),
                elementsBase: (
                    hex: response.elementsBase.hex,
                    a: response.elementsBase.alpha
                ),
                tint: (hex: response.tint.hex, a: response.tint.alpha),
                textColor: (
                    hex: response.textColor.hex,
                    a: response.textColor.alpha
                )
            )
        )
    }
    
    func presentFriends(_ response: Model.FriendsList.Response) {
        let items = response.users.map { user in
            Model.FriendsList.ViewModel.FriendCell(
                id: user.id,
                username: user.username,
                photoURL: user.photoURL,
                avatarData: itemsById[user.id]?.avatarData,
                baseColor: cellBaseColor,
                tintColor: cellTintColor,
                textColor: cellTextColor
            )
        }
        
        orderedIds = items.map { $0.id }
        itemsById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
        controller?.displayFriends(
            Model.FriendsList.ViewModel(items: items)
        )
    }
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response) {
        guard var item = itemsById[response.userId] else { return }
        guard item.avatarData != response.avatarData else { return }
        
        item = Model.FriendsList.ViewModel.FriendCell(
            id: item.id,
            username: item.username,
            photoURL: item.photoURL,
            avatarData: response.avatarData,
            baseColor: item.baseColor,
            tintColor: item.tintColor,
            textColor: item.textColor
        )
        itemsById[response.userId] = item
        
        controller?.displayAvatarUpdate(
            Model.AvatarUpdate.ViewModel(userId: response.userId)
        )
    }
    
    func presentAddingState(_ response: Model.AddingState.Response) {
        controller?.displayAddingState(
            Model.AddingState.ViewModel(isAdding: response.isAdding)
        )
    }
    
    func presentError(_ response: Model.ShowError.Response) {
        controller?.displayError(
            Model.ShowError.ViewModel(
                errorTitle: Constants.errorTitle,
                errorDescription: response.error.localizedDescription,
                buttonText: Constants.alertOk
            )
        )
    }
}

extension AddChatMemberPresenter: AddChatMemberTableDataLogic {
    func userIds() -> [String] {
        orderedIds
    }
    
    func item(for userId: String) -> Model.FriendsList.ViewModel.FriendCell? {
        itemsById[userId]
    }
}
