//
//  ChatTasksModels.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import Foundation

// Модели для передачи данных между слоями экрана задач
struct ChatTasksModels {
    
    // Модели для старта экрана
    enum Start {
        struct Response {
            let bg: ColorModel
            let bgGradient: ColorModel
            let firstGradient: ColorModel
            let secondGradient: ColorModel
            let elementsBase: ColorModel
            let tint: ColorModel
            let textColor: ColorModel
        }
        
        struct ViewModel {
            let bg: (hex: String, a: CGFloat)
            let bgGradient: (hex: String, a: CGFloat)
            let firstGradient: (hex: String, a: CGFloat)
            let secondGradient: (hex: String, a: CGFloat)
            let elementsBase: (hex: String, a: CGFloat)
            let tint: (hex: String, a: CGFloat)
            let textColor: (hex: String, a: CGFloat)
        }
    }
    
    // Модели для отображения списка задач
    enum TasksList {
        struct Response {
            let tasks: [ChatTaskModel]
            let disabledVoteTaskIds: Set<String>
        }
        
        struct ViewModel {
            struct TaskCell {
                let id: String
                let text: String
                let isCompleted: Bool
                let isVoteButtonEnabled: Bool
                let baseColor: (hex: String, a: CGFloat)
                let textColor: (hex: String, a: CGFloat)
            }
            
            let activeItems: [TaskCell]
            let completedItems: [TaskCell]
        }
    }
    
    // Модели для отображения ошибок
    enum ShowError {
        struct Response {
            let error: Error
        }
        
        struct ViewModel {
            let errorTitle: String
            let errorDescription: String
            let buttonText: String
        }
    }
}
