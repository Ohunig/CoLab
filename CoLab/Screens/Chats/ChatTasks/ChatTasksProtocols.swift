//
//  ChatTasksProtocols.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import Foundation

// Описывает бизнес логику экрана задач
protocol ChatTasksBusinessLogic: AnyObject {
    typealias Model = ChatTasksModels
    
    // Начальные настройки экрана
    func loadStart()
    
    // Запуск live updates задач
    func startTasksUpdates()
    
    // Остановка live updates задач
    func stopTasksUpdates()
    
    // Создание новой задачи
    func createTask(text: String)
    
    // Вынос задачи на голосование в чат
    func sendTaskToVote(taskId: String)
}

// Даёт контроллеру уже подготовленные данные для конкретной ячейки
protocol ChatTasksTableDataLogic: AnyObject {
    typealias Model = ChatTasksModels
    
    func activeTaskIds() -> [String]
    
    func completedTaskIds() -> [String]
    
    func item(for taskId: String) -> Model.TasksList.ViewModel.TaskCell?
}

// Описывает логику презентации
protocol ChatTasksPresentationLogic: AnyObject {
    typealias Model = ChatTasksModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentTasks(_ response: Model.TasksList.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

// Описывает логику отображения
protocol ChatTasksDisplayLogic: AnyObject {
    typealias Model = ChatTasksModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayTasks(_ viewModel: Model.TasksList.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
