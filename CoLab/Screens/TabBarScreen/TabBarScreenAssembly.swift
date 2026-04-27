//
//  TabBarScreenAssembly.swift
//  CoLab
//
//  Created by User on 07.03.2026.
//

import UIKit
import Swinject

// Сборка экрана
enum TabBarScreenAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build() -> UIViewController {
        let presenter = TabBarPresenter()
        
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = TabBarInteractor(
            presenter: presenter,
            colorRepository: colorRepository
        )
        // Так как оказалось, что ViewDidLoad контроллера запускается раньше чем presenter.controller = viewController срабатывает по неопределённой причине, вынужден запускать loadStart насильно сразу после полной сборки экрана
        defer {
            interactor.loadStart()
        }
        
        let viewController = TabBarController(
            interactor: interactor
        )
        // Все нужные экраны прокидываем в свойство таб бара
        let chats = ChatsBranchAssembly.build()
        let searchChats = SearchChatsBranchAssembly.build()
        let v3 = UINavigationController(rootViewController: UIViewController())
        let settings = SettingsBranchAssembly.build()
//        let v2 = UINavigationController(rootViewController: DemoVC(text: "Search", color: .black))
//        let v3 = UINavigationController(rootViewController: DemoVC(text: "Profile", color: .systemGreen))
//        let v4 = UINavigationController(rootViewController: DemoVC(text: "Settings", color: .systemPurple))
        viewController.viewControllers = [chats, searchChats, v3, settings]
        
        presenter.controller = viewController
        return viewController
    }
}
