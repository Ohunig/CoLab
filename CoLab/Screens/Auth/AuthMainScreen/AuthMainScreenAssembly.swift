//
//  AuthMainScreenAssembly.swift
//  CoLab
//
//  Created by User on 04.02.2026.
//

import Foundation
import UIKit
import Swinject

// Сборщик экрана
enum AuthMainScreenAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UIViewController {
        let presenter = AuthMainScreenPresenter()
        
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let authRouter = CompositionRoot.container.resolve(
            AuthRoutingLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = AuthMainScreenInteractor(
            presenter: presenter,
            colorRepository: colorRepository,
            router: authRouter
        )
        let viewController = AuthMainScreenViewController(
            interactor: interactor
        )
        presenter.controller = viewController
        return viewController
    }
}
