//
//  CreateChatPresenter.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import Foundation

final class CreateChatPresenter: CreateChatPresentationLogic, CreateChatTableDataLogic {
    
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
        static let defaultBaseColor = (hex: "#FFFFFF", a: CGFloat(0.35))
        static let defaultTextColor = (hex: "#FFFFFF", a: CGFloat(1))
        static let defaultTintColor = (hex: "#FFFFFF", a: CGFloat(1))
    }
    
    weak var controller: CreateChatDisplayLogic?
    
    private var orderedIds: [String] = []
    private var itemsById: [String: Model.MembersList.ViewModel.MemberCell] = [:]
    private var cellBaseColor = Constants.defaultBaseColor
    private var cellTextColor = Constants.defaultTextColor
    private var cellTintColor = Constants.defaultTintColor
    
    // MARK: Present
    
    func presentStart(_ response: Model.Start.Response) {
        cellBaseColor = (
            hex: response.elementsBase.hex,
            a: response.elementsBase.alpha
        )
        cellTextColor = (
            hex: response.textColor.hex,
            a: response.textColor.alpha
        )
        cellTintColor = (
            hex: response.tint.hex,
            a: response.tint.alpha
        )
        
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (hex: response.bgGradient.hex, a: response.bgGradient.alpha),
                firstGradient: (hex: response.firstGradient.hex, a: response.firstGradient.alpha),
                secondGradient: (hex: response.secondGradient.hex, a: response.secondGradient.alpha),
                elementsBase: (hex: response.elementsBase.hex, a: response.elementsBase.alpha),
                tint: (hex: response.tint.hex, a: response.tint.alpha),
                textColor: (hex: response.textColor.hex, a: response.textColor.alpha)
            )
        )
    }
    
    func presentMembers(_ response: Model.MembersList.Response) {
        let previousItemsById = itemsById
        
        let items = response.members.map { member in
            let previousItem = previousItemsById[member.id]
            let hasRemoteAvatar = member.avatarURL?.isEmpty == false
            let preservedAvatarData: Data?
            let isAvatarLoading: Bool
            
            if previousItem?.avatarURL == member.avatarURL {
                preservedAvatarData = previousItem?.avatarData
                isAvatarLoading = previousItem?.isAvatarLoading
                    ?? hasRemoteAvatar
            } else {
                preservedAvatarData = nil
                isAvatarLoading = hasRemoteAvatar
            }
            
            return Model.MembersList.ViewModel.MemberCell(
                id: member.id,
                username: member.username,
                baseColor: cellBaseColor,
                textColor: cellTextColor,
                tintColor: cellTintColor,
                avatarURL: member.avatarURL,
                avatarData: preservedAvatarData,
                isAvatarLoading: isAvatarLoading
            )
        }
        
        let updatedMemberIds = items.compactMap { item -> String? in
            guard let previousItem = previousItemsById[item.id] else { return item.id }
            guard previousItem.username != item.username
                || previousItem.baseColor != item.baseColor
                || previousItem.textColor != item.textColor
                || previousItem.tintColor != item.tintColor
                || previousItem.avatarURL != item.avatarURL
                || previousItem.avatarData != item.avatarData
                || previousItem.isAvatarLoading != item.isAvatarLoading
            else {
                return nil
            }
            return item.id
        }
        
        orderedIds = items.map { $0.id }
        itemsById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
        controller?.displayMembers(
            Model.MembersList.ViewModel(
                items: items,
                updatedMemberIds: updatedMemberIds
            )
        )
    }
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response) {
        guard var item = itemsById[response.memberId] else { return }
        guard item.avatarData != response.avatarData || item.isAvatarLoading else {
            return
        }
        
        item = Model.MembersList.ViewModel.MemberCell(
            id: item.id,
            username: item.username,
            baseColor: item.baseColor,
            textColor: item.textColor,
            tintColor: item.tintColor,
            avatarURL: item.avatarURL,
            avatarData: response.avatarData,
            isAvatarLoading: false
        )
        itemsById[response.memberId] = item
        
        // Обновляем только нужную ячейку участника
        controller?.displayAvatarUpdate(
            Model.AvatarUpdate.ViewModel(memberId: response.memberId)
        )
    }
    
    func presentChatAvatar(_ response: Model.ChatAvatar.Response) {
        controller?.displayChatAvatar(
            Model.ChatAvatar.ViewModel(
                avatarData: response.avatarData
            )
        )
    }
    
    func presentDataValidation(_ response: Model.Validation.Response) {
        controller?.displayDataValidation(
            Model.Validation.ViewModel(isValid: response.isValid)
        )
    }
    
    func presentCreatingState(_ response: Model.CreatingState.Response) {
        controller?.displayCreatingState(
            Model.CreatingState.ViewModel(isCreating: response.isCreating)
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
    
    // MARK: Table data
    
    func memberIds() -> [String] {
        orderedIds
    }
    
    func item(for memberId: String) -> Model.MembersList.ViewModel.MemberCell? {
        itemsById[memberId]
    }
}
