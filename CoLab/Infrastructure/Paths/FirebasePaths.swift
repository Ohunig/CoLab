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
}
