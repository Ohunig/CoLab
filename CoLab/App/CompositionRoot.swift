//
//  CompositionRoot.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation
import Swinject

// Используется DI container
final class CompositionRoot {
    
    static let container: Container = {
        let container = Container()
        
        // Repositories
        container.register(ColorStorageLogic.self) { _ in ColorRepository() }
            .inObjectScope(.container)
        
        // Network services
        container.register(AuthLogic.self) { _ in AuthService() }
            .inObjectScope(.container)
        
        // Routers
        container.register(AuthRoutingLogic.self) { _ in AuthRouter() }
            .inObjectScope(.container)
        container.register(SettingsRoutingLogic.self) { _ in SettingsRouter() }
            .inObjectScope(.container)
        
        return container
    }()
    
    // Чтобы объект не создавался
    private init() {}
}
