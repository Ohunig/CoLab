//
//  AvatarServiceLogic.swift
//  CoLab
//
//  Created by User on 11.03.2026.
//

import Foundation
import Combine

// Логика сервиса для подтягивания / публикации ползьзовательских аватаров
protocol AvatarServiceLogic: AnyObject {
    
    // Возвращает паблишера необходимого для получения данных аватара
    func avatarDataPublisher(for profile: UserModel) -> AnyPublisher<Data?, Never>
    
    // Возвращает паблишера с путём до опубликованного аватара или же с ошибкой
    func uploadAvatarData(
        data: Data,
        for profile: UserModel
    ) -> AnyPublisher<String, Error>
}
