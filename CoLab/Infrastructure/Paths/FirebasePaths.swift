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
        case searchKeywords
        case friendIds
        
        var path: String {
            switch self {
            case .username:
                "username"
            case .photoURL:
                "photoURL"
            case .searchKeywords:
                "searchKeywords"
            case .friendIds:
                "friendIds"
            }
        }
    }
    
    // Обозначения для таблицы чатов
    enum Chats {
        static let root = "chats"
        
        case memberIds
        case lastMessageDate
        case title
        case description
        case isPublic
        case lastMessageText
        case avatarURL
        case searchKeywords
        
        var path: String {
            switch self {
            case .memberIds:
                "memberIds"
            case .lastMessageDate:
                "lastMessageDate"
            case .title:
                "title"
            case .description:
                "description"
            case .isPublic:
                "isPublic"
            case .lastMessageText:
                "lastMessageText"
            case .avatarURL:
                "avatarURL"
            case .searchKeywords:
                "searchKeywords"
            }
        }
    }
    
    enum Messages {
        static let root = "messages"
        
        case kind
        case senderId
        case memberId
        case text
        case createdAt
        case taskId
        case taskText
        case votesFor
        case votesAgainst
        case isResolved
        
        var path: String {
            switch self {
            case .kind:
                "kind"
            case .senderId:
                "senderId"
            case .memberId:
                "memberId"
            case .text:
                "text"
            case .createdAt:
                "createdAt"
            case .taskId:
                "taskId"
            case .taskText:
                "taskText"
            case .votesFor:
                "votesFor"
            case .votesAgainst:
                "votesAgainst"
            case .isResolved:
                "isResolved"
            }
        }
    }
    
    // Обозначения для таблицы задач конкретного чата
    enum Tasks {
        static let root = "tasks"
        
        case text
        case createdBy
        case isCompleted
        case createdAt
        case completedAt
        case activeVoteMessageId
        
        var path: String {
            switch self {
            case .text:
                "text"
            case .createdBy:
                "createdBy"
            case .isCompleted:
                "isCompleted"
            case .createdAt:
                "createdAt"
            case .completedAt:
                "completedAt"
            case .activeVoteMessageId:
                "activeVoteMessageId"
            }
        }
    }
}
