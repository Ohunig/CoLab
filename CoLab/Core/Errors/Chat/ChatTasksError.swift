//
//  ChatTasksError.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import Foundation

enum ChatTasksError: LocalizedError {
    private struct Constants {
        static let permissionDesc = "Нет доступа к задачам"
        static let networkDesc = "Проблемы с интернетом"
        static let emptyTextDesc = "Пустую задачу нельзя добавить"
        static let activeVoteExistsDesc = "По этой задаче уже идёт голосование"
        static let unknownDesc = "Не удалось выполнить действие с задачей"
    }
    
    case permissionDenied
    case emptyText
    case activeVoteExists
    case network
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            Constants.permissionDesc
        case .emptyText:
            Constants.emptyTextDesc
        case .activeVoteExists:
            Constants.activeVoteExistsDesc
        case .network:
            Constants.networkDesc
        case .unknown:
            Constants.unknownDesc
        }
    }
}
