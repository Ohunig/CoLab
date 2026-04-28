//
//  ChatModel.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

struct ChatModel: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let lastMessageText: String?
    let lastMessageDate: Date?
    let avatarURL: String?
    let memberIds: [String]
}

