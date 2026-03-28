//
//  ChatMessageModel.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation

struct ChatMessageModel: Codable, Equatable, Identifiable {
    let id: String
    let senderId: String
    let text: String
    let createdAt: Date
}
