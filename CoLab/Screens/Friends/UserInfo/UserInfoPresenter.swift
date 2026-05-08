//
//  UserInfoPresenter.swift
//  CoLab
//
//  Created by User on 08.05.2026.
//

import Foundation

final class UserInfoPresenter: UserInfoPresentationLogic {
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
    }
    
    weak var controller: UserInfoDisplayLogic?
    
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
