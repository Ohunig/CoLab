//
//  ChatTasksAssembly.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import UIKit
import Swinject

// Сборка экрана задач чата
enum ChatTasksAssembly {
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static func build(
        chatId: String,
        memberIds: [String]
    ) -> UIViewController {
        let presenter = ChatTasksPresenter()
        
        guard let colorRepository = CompositionRoot.container.resolve(
            ColorStorageLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        guard let tasksService = CompositionRoot.container.resolve(
            ChatTasksLogic.self
        ) else {
            fatalError(Constants.notAllServicesRegistered)
        }
        
        let interactor = ChatTasksInteractor(
            chatId: chatId,
            memberIds: memberIds,
            presenter: presenter,
            colorRepository: colorRepository,
            tasksService: tasksService
        )
        
        let controller = ChatTasksController(
            interactor: interactor,
            tableDataProvider: presenter
        )
        presenter.controller = controller
        
        return controller
    }
}
