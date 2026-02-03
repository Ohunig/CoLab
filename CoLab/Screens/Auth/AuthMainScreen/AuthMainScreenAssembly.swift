//
//  AuthMainScreenAssembly.swift
//  CoLab
//
//  Created by User on 04.02.2026.
//

import Foundation
import UIKit

// Сборщик экрана
enum AuthMainScreenAssembly {
    
    static func build() -> UIViewController {
        let presenter = AuthMainScreenPresenter()
        let interactor = AuthMainScreenInteractor(
            presenter: presenter,
            colorRepository: ColorRepository()
        )
        let viewController = AuthMainScreenViewController(
            interactor: interactor
        )
        presenter.controller = viewController
        return viewController
    }
}
