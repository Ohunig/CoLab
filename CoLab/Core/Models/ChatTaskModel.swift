//
//  ChatTaskModel.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import Foundation

struct ChatTaskModel: Codable, Equatable, Identifiable {
    let id: String
    let text: String
    let createdBy: String
    let isCompleted: Bool
    let createdAt: Date
    let completedAt: Date?
    let activeVoteMessageId: String?
}
