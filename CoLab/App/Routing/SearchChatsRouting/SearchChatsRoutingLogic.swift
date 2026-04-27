//
//  SearchChatsRoutingLogic.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import UIKit

protocol SearchChatsRoutingLogic: AnyObject {
    var navigationController: UINavigationController? { get set }
    
    func routeToChatInfo(
        chatTitle: String,
        chatAvatarURL: String?,
        memberIds: [String]
    )
}
