//
//  ChatTasksInteractor.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import Foundation
import Combine

final class ChatTasksInteractor: ChatTasksBusinessLogic {
    
    private let chatId: String
    private let memberIds: [String]
    private let presenter: ChatTasksPresentationLogic
    private let colorRepository: ColorStorageLogic
    private let tasksService: ChatTasksLogic
    
    private var tasks: [ChatTaskModel] = []
    private var activeVoteTaskIds = Set<String>()
    private var optimisticActiveVoteTaskIds = Set<String>()
    private var requestsCancellables = Set<AnyCancellable>()
    private var tasksCancellable: AnyCancellable?
    private var activeVotesCancellable: AnyCancellable?
    private var sendingVoteTaskIds = Set<String>()
    
    // MARK: Lifecycle
    
    init(
        chatId: String,
        memberIds: [String],
        presenter: ChatTasksPresentationLogic,
        colorRepository: ColorStorageLogic,
        tasksService: ChatTasksLogic
    ) {
        self.chatId = chatId
        self.memberIds = memberIds
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.tasksService = tasksService
    }
    
    deinit {
        stopTasksUpdates()
    }
    
    // MARK: Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                firstGradient: colorRepository.firstGradientColor,
                secondGradient: colorRepository.secondGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                tint: colorRepository.tintColor,
                textColor: colorRepository.mainTextColor
            )
        )
    }
    
    func startTasksUpdates() {
        guard tasksCancellable == nil,
              activeVotesCancellable == nil else {
            return
        }
        
        tasksService.startListeningTasks(chatId: chatId)
        tasksCancellable = tasksService.taskUpdatesPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                
                switch result {
                case let .failure(error):
                    self.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                case let .success(tasks):
                    self.tasks = tasks
                    self.presentTasks()
                }
            }
        
        tasksService.startListeningActiveTaskVotes(
            chatId: chatId,
            memberCount: memberIds.count
        )
        activeVotesCancellable = tasksService.activeTaskVoteUpdatesPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                
                switch result {
                case let .failure(error):
                    self.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                case let .success(taskIds):
                    self.activeVoteTaskIds = taskIds
                    self.optimisticActiveVoteTaskIds.formIntersection(taskIds)
                    self.presentTasks()
                }
            }
    }
    
    func stopTasksUpdates() {
        tasksCancellable?.cancel()
        tasksCancellable = nil
        activeVotesCancellable?.cancel()
        activeVotesCancellable = nil
        tasksService.stopListeningTasks()
        tasksService.stopListeningActiveTaskVotes()
    }
    
    func createTask(text: String) {
        tasksService.createTask(
            text: text,
            chatId: chatId
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard case let .failure(error) = completion else { return }
                self?.presenter.presentError(
                    Model.ShowError.Response(error: error)
                )
            },
            receiveValue: { }
        )
        .store(in: &requestsCancellables)
    }
    
    func sendTaskToVote(taskId: String) {
        guard !sendingVoteTaskIds.contains(taskId) else { return }
        guard !activeVoteTaskIds.contains(taskId) else { return }
        guard !optimisticActiveVoteTaskIds.contains(taskId) else { return }
        guard let task = tasks.first(where: { $0.id == taskId }) else { return }
        guard !task.isCompleted else { return }
        
        sendingVoteTaskIds.insert(taskId)
        presentTasks()
        tasksService.sendTaskVoteMessage(
            task: task,
            chatId: chatId
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.sendingVoteTaskIds.remove(taskId)
                
                switch completion {
                case .finished:
                    self.optimisticActiveVoteTaskIds.insert(taskId)
                case let .failure(error):
                    self.presenter.presentError(
                        Model.ShowError.Response(error: error)
                    )
                }
                
                self.presentTasks()
            },
            receiveValue: { }
        )
        .store(in: &requestsCancellables)
    }
    
    private func presentTasks() {
        presenter.presentTasks(
            Model.TasksList.Response(
                tasks: tasks,
                disabledVoteTaskIds: sendingVoteTaskIds
                    .union(activeVoteTaskIds)
                    .union(optimisticActiveVoteTaskIds)
            )
        )
    }
}
