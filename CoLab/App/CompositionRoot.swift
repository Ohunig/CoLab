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
        
        func resolveSearchKeywordsBuilder(
            _ resolver: Resolver
        ) -> SearchKeywordsBuilder {
            guard let searchKeywordsBuilder = resolver.resolve(
                SearchKeywordsBuilder.self
            ) else {
                fatalError(Constants.notAllServicesRegistered)
            }
            return searchKeywordsBuilder
        }
        
        // Репозитории
        container.register(ColorStorageLogic.self) { _ in ColorRepository() }
            .inObjectScope(.container)
        container.register(SearchKeywordsBuilder.self) { _ in
            SearchKeywordsBuilder()
        }.inObjectScope(.transient)
        
        // Network сервисы
        container.register(AuthLogic.self) { resolver in
            AuthService(
                searchKeywordsBuilder: resolveSearchKeywordsBuilder(resolver)
            )
        }.inObjectScope(.container)
        container.register(UserServiceLogic.self) { resolver in
            UserService(
                userCache: UserCacheStorage(),
                searchKeywordsBuilder: resolveSearchKeywordsBuilder(resolver)
            )
        }.inObjectScope(.transient)
        container.register(AvatarServiceLogic.self) { _ in AvatarService(avatarsCache: AvatarCacheStorage()) }
            .inObjectScope(.transient)
        container.register(UserChatListLogic.self) { _ in UserChatListService() }
            .inObjectScope(.transient)
        container.register(SearchChatsListLogic.self) { resolver in
            SearchChatsListService(
                searchKeywordsBuilder: resolveSearchKeywordsBuilder(resolver)
            )
        }.inObjectScope(.transient)
        container.register(SearchFriendsListLogic.self) { resolver in
            SearchFriendsListService(
                searchKeywordsBuilder: resolveSearchKeywordsBuilder(resolver)
            )
        }.inObjectScope(.transient)
        container.register(ChatLogic.self) { _ in ChatService() }
            .inObjectScope(.transient)
        container.register(ChatMessagesLogic.self) { _ in ChatMessagesService() }
            .inObjectScope(.transient)
        
        // Роутеры
        container.register(AuthRoutingLogic.self) { _ in AuthRouter() }
            .inObjectScope(.container)
        container.register(ChatsRoutingLogic.self) { _ in ChatsRouter() }
            .inObjectScope(.container)
        container.register(SearchChatsRoutingLogic.self) { _ in SearchChatsRouter() }
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
