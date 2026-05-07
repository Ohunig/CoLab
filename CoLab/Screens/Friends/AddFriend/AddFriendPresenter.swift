//
//  AddFriendPresenter.swift
//  CoLab
//
//  Created by User on 06.05.2026.
//

import Foundation

final class AddFriendPresenter: AddFriendPresentationLogic {
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
        static let addButtonTitle = "Добавить в друзья"
        static let addButtonLoadingTitle = "Добавляем..."
        static let addedButtonTitle = "В друзьях"
        static let selfButtonTitle = "Это вы"
    }
    
    weak var controller: AddFriendDisplayLogic?
    
    func presentStart(_ response: Model.Start.Response) {
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (
                    hex: response.bgGradient.hex,
                    a: response.bgGradient.alpha
                ),
                elementsBase: (
                    hex: response.elementsBase.hex,
                    a: response.elementsBase.alpha
                ),
                tint: (hex: response.tint.hex, a: response.tint.alpha),
                textColor: (
                    hex: response.textColor.hex,
                    a: response.textColor.alpha
                ),
                firstGradient: (
                    hex: response.firstGradient.hex,
                    a: response.firstGradient.alpha
                ),
                secondGradient: (
                    hex: response.secondGradient.hex,
                    a: response.secondGradient.alpha
                )
            )
        )
    }
    
    func presentUserData(_ response: Model.UserData.Response) {
        controller?.displayUserData(
            Model.UserData.ViewModel(
                avatarData: response.avatarData,
                isAvatarLoading: response.isAvatarLoading,
                username: response.username
            )
        )
    }
    
    func presentAddButtonState(_ response: Model.AddButtonState.Response) {
        let title: String
        if response.isSelf {
            title = Constants.selfButtonTitle
        } else if response.isFriend {
            title = Constants.addedButtonTitle
        } else if response.isLoading {
            title = Constants.addButtonLoadingTitle
        } else {
            title = Constants.addButtonTitle
        }
        
        controller?.displayAddButtonState(
            Model.AddButtonState.ViewModel(
                title: title,
                isEnabled: !response.isLoading
                    && !response.isFriend
                    && !response.isSelf
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
}
