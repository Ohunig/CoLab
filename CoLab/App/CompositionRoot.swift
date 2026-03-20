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
    
    private struct Constants {
        static let notAllServicesRegistered = "Not all dependencies registered"
    }
    
    static let container: Container = {
        let container = Container()
        
        // Репозитории
        container.register(ColorStorageLogic.self) { _ in ColorRepository() }
            .inObjectScope(.container)
        
        // Network сервисы
        container.register(AuthLogic.self) { _ in AuthService() }
            .inObjectScope(.container)
        container.register(UserServiceLogic.self) { _ in UserService(userCache: UserCacheStorage()) }
            .inObjectScope(.transient)
        container.register(AvatarServiceLogic.self) { _ in AvatarService(avatarsCache: AvatarCacheStorage()) }
            .inObjectScope(.transient)
        container.register(UserChatListLogic.self) { _ in UserChatListService() }
            .inObjectScope(.transient)
        
        // Роутеры
        container.register(AuthRoutingLogic.self) { _ in AuthRouter() }
            .inObjectScope(.container)
        container.register(SettingsRoutingLogic.self) { resolver in
            guard let authRouter = resolver.resolve(
                AuthRoutingLogic.self
            ) else {
                // Специально сделано чтобы приложение падало с ошибкой так как без всех зарегестрированных зависимостей не может нормально работать
                fatalError(Constants.notAllServicesRegistered)
            }
            return SettingsRouter(authRouter: authRouter)
        }.inObjectScope(.container)
        
        return container
    }()
    
    // Чтобы объект не создавался
    private init() {}
}
