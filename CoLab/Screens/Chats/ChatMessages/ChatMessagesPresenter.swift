//
//  ChatMessagesPresenter.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation

final class ChatMessagesPresenter: ChatMessagesPresentationLogic, ChatMessagesCollectionDataLogic {
    
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
        static let defaultIncomingBase = (hex: "#4C4232", a: CGFloat(1))
        static let defaultIncomingBorder = (hex: "#4C4232", a: CGFloat(1))
        static let defaultOutgoingGradientStart = (hex: "#4C4232", a: CGFloat(1))
        static let defaultOutgoingGradientEnd = (hex: "#4C4232", a: CGFloat(1))
        static let defaultIncomingText = (hex: "#FFFFFF", a: CGFloat(1))
        static let defaultOutgoingText = (hex: "#FFFFFF", a: CGFloat(1))
        static let defaultSenderName = (hex: "#FFFFFF", a: CGFloat(0.72))
    }
    
    weak var controller: ChatMessagesDisplayLogic?
    
    private var orderedIds: [String] = []
    private var itemsById: [String: Model.MessagesList.ViewModel.MessageItem] = [:]
    
    private var incomingBaseColor = Constants.defaultIncomingBase
    private var incomingBorderColor = Constants.defaultIncomingBorder
    private var outgoingGradientStartColor = Constants.defaultOutgoingGradientStart
    private var outgoingGradientEndColor = Constants.defaultOutgoingGradientEnd
    private var incomingTextColor = Constants.defaultIncomingText
    private var outgoingTextColor = Constants.defaultOutgoingText
    private var senderNameColor = Constants.defaultSenderName
    
    // MARK: Presentation logic
    
    // Сохраняем текущую палитру экрана чтобы потом использовать её при построении сообщений
    func presentStart(_ response: Model.Start.Response) {
        incomingBaseColor = (hex: response.incomingBase.hex, a: response.incomingBase.alpha)
        incomingBorderColor = (hex: response.incomingBorder.hex, a: response.incomingBorder.alpha)
        outgoingGradientStartColor = (hex: response.outgoingGradientStart.hex,a: response.outgoingGradientStart.alpha)
        outgoingGradientEndColor = (hex: response.outgoingGradientEnd.hex, a: response.outgoingGradientEnd.alpha)
        incomingTextColor = (hex: response.incomingTextColor.hex, a: response.incomingTextColor.alpha)
        outgoingTextColor = (hex: response.outgoingTextColor.hex,a: response.outgoingTextColor.alpha)
        senderNameColor = (hex: response.senderNameColor.hex,a: response.senderNameColor.alpha)
        
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (hex: response.bgGradient.hex, a: response.bgGradient.alpha),
                incomingBase: incomingBaseColor,
                incomingBorder: incomingBorderColor,
                outgoingGradientStart: outgoingGradientStartColor,
                outgoingGradientEnd: outgoingGradientEndColor,
                incomingTextColor: incomingTextColor,
                outgoingTextColor: outgoingTextColor,
                senderNameColor: senderNameColor
            )
        )
    }
    
    func presentChatAvatar(_ response: Model.ChatAvatar.Response) {
        controller?.displayChatAvatar(
            Model.ChatAvatar.ViewModel(
                avatarData: response.avatarData
            )
        )
    }
    
    func presentMessages(_ response: Model.MessagesList.Response) {
        let previousItemsById = itemsById
        
        // Собираем уже готовые display item'ы для коллекции.
        // Контроллер потом только забирает их по id и применяет к ячейке.
        let items = response.messages.map { message in
            let isOutgoing = message.senderId == response.currentUserId
            let senderData = response.senderDataById[message.senderId]
            
            return Model.MessagesList.ViewModel.MessageItem(
                id: message.id,
                text: message.text,
                direction: isOutgoing ? .outgoing : .incoming,
                senderName: isOutgoing ? nil : senderData?.username,
                avatarData: isOutgoing ? nil : senderData?.avatarData,
                baseColor: isOutgoing ? outgoingGradientEndColor : incomingBaseColor,
                borderColor: isOutgoing ? nil : incomingBorderColor,
                gradientStartColor: isOutgoing ? outgoingGradientStartColor : nil,
                gradientEndColor: isOutgoing ? outgoingGradientEndColor : nil,
                textColor: isOutgoing ? outgoingTextColor : incomingTextColor,
                senderTextColor: isOutgoing ? nil : senderNameColor
            )
        }
        
        orderedIds = items.map(\.id)
        itemsById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
        // Отдельно считаем какие сообщения реально поменялись по контенту.
        // Это нужно чтобы не перерисовывать всю коллекцию когда обновился только sender data.
        let updatedMessageIds = items.compactMap { item -> String? in
            guard let previousItem = previousItemsById[item.id] else {
                return nil
            }
            return hasSameDisplayState(lhs: previousItem, rhs: item) ? nil : item.id
        }
        
        controller?.displayMessages(
            Model.MessagesList.ViewModel(
                items: items,
                updatedMessageIds: updatedMessageIds
            )
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
    
    // MARK: Collection data
    
    func messageIds() -> [String] {
        orderedIds
    }
    
    // Контроллер работает не с массивом целиком, а с item'ом по конкретному id
    func item(for messageId: String) -> Model.MessagesList.ViewModel.MessageItem? {
        itemsById[messageId]
    }
    
    // MARK: Compare items
    
    // MessageItem специально не делает Equatable на уровне модели.
    // Сравнение display-state держим локально в presenter.
    private func hasSameDisplayState(
        lhs: Model.MessagesList.ViewModel.MessageItem,
        rhs: Model.MessagesList.ViewModel.MessageItem
    ) -> Bool {
        lhs.id == rhs.id
        && lhs.text == rhs.text
        && hasSameDirection(lhs.direction, rhs.direction)
        && lhs.senderName == rhs.senderName
        && lhs.avatarData == rhs.avatarData
        && lhs.baseColor.hex == rhs.baseColor.hex
        && lhs.baseColor.a == rhs.baseColor.a
        && lhs.borderColor?.hex == rhs.borderColor?.hex
        && lhs.borderColor?.a == rhs.borderColor?.a
        && lhs.gradientStartColor?.hex == rhs.gradientStartColor?.hex
        && lhs.gradientStartColor?.a == rhs.gradientStartColor?.a
        && lhs.gradientEndColor?.hex == rhs.gradientEndColor?.hex
        && lhs.gradientEndColor?.a == rhs.gradientEndColor?.a
        && lhs.textColor.hex == rhs.textColor.hex
        && lhs.textColor.a == rhs.textColor.a
        && lhs.senderTextColor?.hex == rhs.senderTextColor?.hex
        && lhs.senderTextColor?.a == rhs.senderTextColor?.a
    }
    
    private func hasSameDirection(
        _ lhs: Model.MessagesList.ViewModel.Direction,
        _ rhs: Model.MessagesList.ViewModel.Direction
    ) -> Bool {
        switch (lhs, rhs) {
        case (.incoming, .incoming), (.outgoing, .outgoing):
            true
        default:
            false
        }
    }
}
