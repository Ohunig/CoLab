//
//  ChatTasksPresenter.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import Foundation

final class ChatTasksPresenter: ChatTasksPresentationLogic, ChatTasksTableDataLogic {
    
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
        static let defaultBaseColor = (hex: "#FFFFFF", a: CGFloat(0.35))
        static let defaultTextColor = (hex: "#FFFFFF", a: CGFloat(1))
    }
    
    weak var controller: ChatTasksDisplayLogic?
    
    private var activeIds: [String] = []
    private var completedIds: [String] = []
    private var itemsById: [String: Model.TasksList.ViewModel.TaskCell] = [:]
    private var cellBaseColor = Constants.defaultBaseColor
    private var cellTextColor = Constants.defaultTextColor
    
    // MARK: Present
    
    func presentStart(_ response: Model.Start.Response) {
        cellBaseColor = (
            hex: response.elementsBase.hex,
            a: response.elementsBase.alpha
        )
        cellTextColor = (
            hex: response.textColor.hex,
            a: response.textColor.alpha
        )
        
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (hex: response.bgGradient.hex, a: response.bgGradient.alpha),
                firstGradient: (hex: response.firstGradient.hex, a: response.firstGradient.alpha),
                secondGradient: (hex: response.secondGradient.hex, a: response.secondGradient.alpha),
                elementsBase: cellBaseColor,
                tint: (hex: response.tint.hex, a: response.tint.alpha),
                textColor: cellTextColor
            )
        )
    }
    
    func presentTasks(_ response: Model.TasksList.Response) {
        let items = response.tasks.map {
            Model.TasksList.ViewModel.TaskCell(
                id: $0.id,
                text: $0.text,
                isCompleted: $0.isCompleted,
                isVoteButtonEnabled: !$0.isCompleted
                    && $0.activeVoteMessageId == nil
                    && !response.disabledVoteTaskIds.contains($0.id),
                baseColor: cellBaseColor,
                textColor: cellTextColor
            )
        }
        
        activeIds = items.filter { !$0.isCompleted }.map(\.id)
        completedIds = items.filter(\.isCompleted).map(\.id)
        itemsById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
        controller?.displayTasks(
            Model.TasksList.ViewModel(
                activeItems: activeIds.compactMap { itemsById[$0] },
                completedItems: completedIds.compactMap { itemsById[$0] }
            )
        )
    }
    
    func presentError(_ response: Model.ShowError.Response) {
        controller?.displayError(
            Model.ShowError.ViewModel(
                errorTitle: Constants.errorTitle,
                errorDescription: response.error.localizedDescription,
                buttonText: Constants.alertOk
            )
        )
    }
    
    // MARK: Table data
    
    func activeTaskIds() -> [String] {
        activeIds
    }
    
    func completedTaskIds() -> [String] {
        completedIds
    }
    
    func item(for taskId: String) -> Model.TasksList.ViewModel.TaskCell? {
        itemsById[taskId]
    }
}
