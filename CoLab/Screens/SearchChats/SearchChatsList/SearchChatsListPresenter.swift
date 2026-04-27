//
//  SearchChatsListPresenter.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import Foundation

final class SearchChatsListPresenter: SearchChatsListPresentationLogic {
    
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
        static let defaultBaseColor = (hex: "#FFFFFF", a: CGFloat(0.35))
        static let defaultTextColor = (hex: "#FFFFFF", a: CGFloat(1))
        static let defaultStartGradient = (hex: "#FFFFFF", a: CGFloat(1))
        static let defaultEndGradient = (hex: "#FFFFFF", a: CGFloat(1))
    }
    
    weak var controller: SearchChatsListDisplayLogic?
    
    private var orderedIds: [String] = []
    private var itemsById: [String: Model.ChatsList.ViewModel.ChatCell] = [:]
    
    private var cellBaseColor = Constants.defaultBaseColor
    private var cellTextColor = Constants.defaultTextColor
    private var cellStartGradient = Constants.defaultStartGradient
    private var cellEndGradient = Constants.defaultEndGradient
    
    // MARK: Present
    
    func presentStart(_ response: Model.Start.Response) {
        cellBaseColor = (hex: response.elementsBase.hex, a: response.elementsBase.alpha)
        cellTextColor = (hex: response.textColor.hex, a: response.textColor.alpha)
        cellStartGradient = (hex: response.startGradient.hex, a: response.startGradient.alpha)
        cellEndGradient = (hex: response.endGradient.hex, a: response.endGradient.alpha)
        
        
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (hex: response.bgGradient.hex, a: response.bgGradient.alpha),
                elementsBase: (hex: response.elementsBase.hex, a: response.elementsBase.alpha),
                textColor: (hex: response.textColor.hex,a: response.textColor.alpha)
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
        let items = response.chats.map { chat in
            
            return Model.ChatsList.ViewModel.ChatCell(
                id: chat.id,
                title: chat.title,
                baseColor: cellBaseColor,
                textColor: cellTextColor,
                startGradientColor: cellStartGradient,
                endGradientColor: cellEndGradient,
                avatarURL: chat.avatarURL,
                memberIds: chat.memberIds,
                avatarData: itemsById[chat.id]?.avatarData
            )
        }
        
        orderedIds = items.map { $0.id }
        itemsById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
        controller?.displayChats(
            Model.ChatsList.ViewModel(items: items)
        )
    }
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response) {
        guard var item = itemsById[response.chatId] else { return }
        guard item.avatarData != response.avatarData else { return }
        
        item = Model.ChatsList.ViewModel.ChatCell(
            id: item.id,
            title: item.title,
            baseColor: item.baseColor,
            textColor: item.textColor,
            startGradientColor: item.startGradientColor,
            endGradientColor: item.endGradientColor,
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
}

// MARK: - Table data provider extension

extension SearchChatsListPresenter: SearchChatsListTableDataLogic {
    func chatIds() -> [String] {
        orderedIds
    }
    
    func item(for chatId: String) -> Model.ChatsList.ViewModel.ChatCell? {
        itemsById[chatId]
    }
}
