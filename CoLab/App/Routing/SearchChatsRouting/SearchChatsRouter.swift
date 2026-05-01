//
//  SearchChatsRouter.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import UIKit

final class SearchChatsRouter: SearchChatsRoutingLogic {
    private weak var navController: UINavigationController?
    
    var navigationController: UINavigationController? {
        get { navController }
        set { navController = newValue }
    }
    
    func routeToAddChat(
        chatId: String
    ) {
        navigationController?.pushViewController(
            AddChatAssembly.build(
                chatId: chatId
            ),
            animated: true
        )
    }
}
