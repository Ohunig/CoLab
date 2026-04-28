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
    
    func routeToChatInfo(
        chatTitle: String,
        chatDescription: String?,
        chatAvatarURL: String?,
        memberIds: [String]
    ) {
        navigationController?.pushViewController(
            ChatInfoAssembly.build(
                chatTitle: chatTitle,
                chatDescription: chatDescription,
                chatAvatarURL: chatAvatarURL,
                memberIds: memberIds
            ),
            animated: true
        )
    }
}
