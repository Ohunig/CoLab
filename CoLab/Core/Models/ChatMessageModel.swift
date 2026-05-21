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
    case taskVote
}

struct ChatMessageModel: Codable, Equatable, Identifiable {
    let id: String
    let kind: ChatMessageKind
    let senderId: String?
    let memberId: String?
    let text: String
    let createdAt: Date
    let taskId: String?
    let taskText: String?
    let votesFor: [String]
    let votesAgainst: [String]
    let isResolved: Bool
    
    init(
        id: String,
        kind: ChatMessageKind,
        senderId: String?,
        memberId: String?,
        text: String,
        createdAt: Date,
        taskId: String? = nil,
        taskText: String? = nil,
        votesFor: [String] = [],
        votesAgainst: [String] = [],
        isResolved: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.senderId = senderId
        self.memberId = memberId
        self.text = text
        self.createdAt = createdAt
        self.taskId = taskId
        self.taskText = taskText
        self.votesFor = votesFor
        self.votesAgainst = votesAgainst
        self.isResolved = isResolved
    }
}
