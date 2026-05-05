//
//  ChatMessageModel.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import Foundation

enum ChatMessageKind: String, Codable {
    case text
    case memberJoined
    case memberLeft
}

struct ChatMessageModel: Codable, Equatable, Identifiable {
    let id: String
    let kind: ChatMessageKind
    let senderId: String?
    let memberId: String?
    let text: String
    let createdAt: Date
}
