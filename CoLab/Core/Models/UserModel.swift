//
//  UserModel.swift
//  CoLab
//
//  Created by User on 30.01.2026.
//

import Foundation

// Модель юзера
nonisolated
struct UserModel: Codable, Equatable {
    let id: String
    let username: String
    let photoURL: String?
}
