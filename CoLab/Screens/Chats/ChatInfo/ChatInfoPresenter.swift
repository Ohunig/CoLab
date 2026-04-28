//
//  ChatInfoPresenter.swift
//  CoLab
//
//  Created by User on 14.04.2026.
//

import Foundation

final class ChatInfoPresenter: ChatInfoPresentationLogic, ChatInfoTableDataLogic {
    
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
        static let defaultBaseColor = (hex: "#FFFFFF", a: CGFloat(0.35))
        static let defaultTextColor = (hex: "#FFFFFF", a: CGFloat(1))
        static let defaultTintColor = (hex: "#FFFFFF", a: CGFloat(1))
    }
    
    weak var controller: ChatInfoDisplayLogic?
    
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
                elementsBase: (hex: response.elementsBase.hex, a: response.elementsBase.alpha),
                tint: (hex: response.tint.hex, a: response.tint.alpha),
                textColor: (hex: response.textColor.hex, a: response.textColor.alpha)
            )
        )
    }
    
    func presentChatData(_ response: Model.GetChatData.Response) {
        controller?.displayChatData(
            Model.GetChatData.ViewModel(
                avatarData: response.avatarData,
                isAvatarLoading: response.isAvatarLoading,
                title: response.title,
                description: response.description
            )
        )
    }
    
    func presentMembers(_ response: Model.MembersList.Response) {
        let previousItemsById = itemsById
        
        let items = response.members.map { member in
            let preservedAvatarData: Data?
            if previousItemsById[member.id]?.avatarURL == member.avatarURL {
                preservedAvatarData = previousItemsById[member.id]?.avatarData
            } else {
                preservedAvatarData = nil
            }
            
            return Model.MembersList.ViewModel.MemberCell(
                id: member.id,
                username: member.username,
                baseColor: cellBaseColor,
                textColor: cellTextColor,
                tintColor: cellTintColor,
                avatarURL: member.avatarURL,
                avatarData: preservedAvatarData
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
        guard item.avatarData != response.avatarData else { return }
        
        item = Model.MembersList.ViewModel.MemberCell(
            id: item.id,
            username: item.username,
            baseColor: item.baseColor,
            textColor: item.textColor,
            tintColor: item.tintColor,
            avatarURL: item.avatarURL,
            avatarData: response.avatarData
        )
        itemsById[response.memberId] = item
        
        controller?.displayAvatarUpdate(
            Model.AvatarUpdate.ViewModel(memberId: response.memberId)
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
    
    func memberIds() -> [String] {
        orderedIds
    }
    
    func item(for memberId: String) -> Model.MembersList.ViewModel.MemberCell? {
        itemsById[memberId]
    }
}
