//
//  UserInfoRoutingLogic.swift
//  CoLab
//
//  Created by User on 08.05.2026.
//

import UIKit

protocol UserInfoRoutingLogic: AnyObject {
    var navigationController: UINavigationController? { get set }
    
    func routeToUserInfo(userId: String)
    
    func routeBack()
}

extension UserInfoRoutingLogic {
    func routeToUserInfo(userId: String) {
        navigationController?.pushViewController(
            UserInfoAssembly.build(
                userId: userId,
                router: self
            ),
            animated: true
        )
    }
    
    func routeBack() {
        navigationController?.popViewController(animated: true)
    }
}
