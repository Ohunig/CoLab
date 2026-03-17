//
//  ChangeSettingsPresenter.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

final class ChangeSettingsPresenter: ChangeSettingsPresentationLogic {
    
    private struct Constants {
        static let errorTitle = "Что-то пошло не так"
        static let alertOk = "Ok"
    }
    
    weak var controller: ChangeSettingsDisplayLogic?
    
    // MARK: Present
    
    func presentStart(_ response: Model.Start.Response) {
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (hex: response.bgGradient.hex, a: response.bgGradient.alpha),
                firstGradient: (hex: response.firstGradient.hex, a: response.firstGradient.alpha),
                secondGradient: (hex: response.secondGradient.hex, a: response.secondGradient.alpha),
                elementsBase: (hex: response.elementsBase.hex, a: response.elementsBase.alpha),
                tint: (hex: response.tint.hex, a: response.tint.alpha),
                textColor: (hex: response.textColor.hex, a: response.textColor.alpha)
            )
        )
    }
    
    func presentUserData(_ response: Model.GetUserData.Response) {
        controller?.displayUserData(
            Model.GetUserData.ViewModel(
                avatarData: response.avatarData,
                username: response.userData.username
            )
        )
    }
    
    func presentDataValidation(_ response: Model.Validation.Response) {
        controller?.displayDataValidation(
            Model.Validation.ViewModel(
                isValid: response.isValid
            )
        )
    }
    
    func presentUpdateDataResult(_ response: Model.CatchError.Response) {
        controller?.displayUpdateDataResult(
            Model.CatchError.ViewModel(
                errorTitle: Constants.errorTitle,
                errorDescription: response.error.localizedDescription
            )
        )
    }
}
