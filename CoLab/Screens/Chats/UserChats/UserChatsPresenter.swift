//
//  UserChatsPresenter.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

final class UserChatsPresenter: UserChatsPresentationLogic, UserChatsTableDataLogic {
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
        static let defaultBaseColor = (hex: "#FFFFFF", a: CGFloat(0.35))
        static let defaultTextColor = (hex: "#FFFFFF", a: CGFloat(1))
    }
    
    weak var controller: UserChatsDisplayLogic?
    
    private var orderedIds: [String] = []
    private var itemsById: [String: Model.ChatsList.ViewModel.ChatCell] = [:]
    // Храним цвета полученные от interactor чтобы подтягивать их в ячейки
    private var cellBaseColor = Constants.defaultBaseColor
    private var cellTextColor = Constants.defaultTextColor
    
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
        
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (hex: response.bgGradient.hex, a: response.bgGradient.alpha),
                elementsBase: (hex: response.elementsBase.hex, a: response.elementsBase.alpha),
                textColor: (hex: response.textColor.hex, a: response.textColor.alpha)
            )
        )
    }
    
    func presentCurrentUserAvatar(_ response: Model.CurrentUserAvatar.Response) {
        controller?.displayCurrentUserAvatar(
            Model.CurrentUserAvatar.ViewModel(
                avatarData: response.avatarData
            )
        )
    }
    
    func presentChats(_ response: Model.ChatsList.Response) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let previousItemsById = itemsById
        let items: [Model.ChatsList.ViewModel.ChatCell] = response.chats.map { chat in
            let time: String
            if let date = chat.lastMessageDate {
                time = dateFormatter.string(from: date)
            } else {
                time = ""
            }
            
            let subtitle = chat.lastMessageText ?? "Message"
            let preservedAvatarData = itemsById[chat.id]?.avatarData

            return Model.ChatsList.ViewModel.ChatCell(
                id: chat.id,
                title: chat.title,
                description: chat.description,
                subtitle: subtitle,
                time: time,
                baseColor: cellBaseColor,
                textColor: cellTextColor,
                avatarURL: chat.avatarURL,
                memberIds: chat.memberIds,
                avatarData: preservedAvatarData
            )
        }
        
        let updatedChatIds = items.compactMap { item -> String? in
            guard let previousItem = previousItemsById[item.id] else { return nil }
            guard previousItem.title != item.title
                || previousItem.subtitle != item.subtitle
                || previousItem.time != item.time
                || previousItem.baseColor != item.baseColor
                || previousItem.textColor != item.textColor
            else {
                return nil
            }
            return item.id
        }
        
        orderedIds = items.map { $0.id }
        itemsById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
        controller?.displayChats(
            Model.ChatsList.ViewModel(
                items: items,
                updatedChatIds: updatedChatIds
            )
        )
    }
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response) {
        guard var item = itemsById[response.chatId] else { return }
        guard item.avatarData != response.avatarData else { return }
        
        item = Model.ChatsList.ViewModel.ChatCell(
            id: item.id,
            title: item.title,
            description: item.description,
            subtitle: item.subtitle,
            time: item.time,
            baseColor: item.baseColor,
            textColor: item.textColor,
            avatarURL: item.avatarURL,
            memberIds: item.memberIds,
            avatarData: response.avatarData
        )
        itemsById[response.chatId] = item
        
        controller?.displayAvatarUpdate(
            Model.AvatarUpdate.ViewModel(chatId: response.chatId)
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
    
    func chatIds() -> [String] {
        orderedIds
    }
    
    func item(for chatId: String) -> Model.ChatsList.ViewModel.ChatCell? {
        itemsById[chatId]
    }
}
