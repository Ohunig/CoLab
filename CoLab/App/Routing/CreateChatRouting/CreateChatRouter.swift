//
//  CreateChatRouter.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import UIKit

// Навигация внутри ветки создания чата
final class CreateChatRouter: CreateChatRoutingLogic {
    private struct Constants {
        static let modalTopSafeAreaCompensation: CGFloat = 30
    }
    
    private weak var navController: UINavigationController?
    
    var navigationController: UINavigationController? {
        get { navController }
        set { navController = newValue }
    }
    
    func routeToSelectChatMember(
        excludedUserIds: [String],
        onSelectUser: @escaping (UserModel) -> Void
    ) {
        let viewController = SelectChatMemberAssembly.build(
            excludedUserIds: excludedUserIds,
            router: self,
            onSelectUser: onSelectUser
        )
        applyModalCompensation(to: viewController)
        
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    func routeToUserInfo(userId: String) {
        let viewController = UserInfoAssembly.build(
            userId: userId,
            router: self
        )
        applyModalCompensation(to: viewController)
        
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    func routeAfterChatCreated() {
        navigationController?.dismiss(animated: true)
    }
    
    func routeBack() {
        guard let navigationController else { return }
        
        if navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            navigationController.dismiss(animated: true)
        }
    }
    
    private func applyModalCompensation(to viewController: UIViewController) {
        (viewController as? ModalTopSafeAreaCompensating)?
            .setModalTopSafeAreaCompensation(
                Constants.modalTopSafeAreaCompensation
            )
    }
}
