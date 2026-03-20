//
//  FirebasePaths.swift
//  CoLab
//
//  Created by User on 11.03.2026.
//

import Foundation

enum FirebasePaths {
    // Обозначения для таблицы юзеров
    enum Users {
        // Так как не относится к полям файлов, а просто название таблицы
        static let root = "users"
        
        // Поля файлов
        case username
        case photoURL
        
        var path: String {
            switch self {
            case .username:
                "username"
            case .photoURL:
                "photoURL"
            }
        }
    }
    
    // Обозначения для таблицы чатов
    enum Chats {
        static let root = "chats"
        
        case memberIds
        case lastMessageDate
        case title
        case lastMessageText
        case avatarURL
        case categories
        
        var path: String {
            switch self {
            case .memberIds:
                "memberIds"
            case .lastMessageDate:
                "lastMessageDate"
            case .title:
                "title"
            case .lastMessageText:
                "lastMessageText"
            case .avatarURL:
                "avatarURL"
            case .categories:
                "categories"
            }
        }
    }
}
