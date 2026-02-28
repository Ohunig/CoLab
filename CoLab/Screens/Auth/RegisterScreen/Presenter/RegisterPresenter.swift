//
//  RegisterPresenter.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

final class RegisterPresenter: RegisterPresentationLogic {
    
    private struct Constants {
        static let RegisterErrorTitle = "Регистрация не удалась"
    }
    
    weak var controller: RegisterControllerLogic?
    
    // MARK: Present
    
    func presentStart(_ response: Model.Start.Response) {
        // Запрос к контроллеру
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
    
    func presentDataValidation(_ response: Model.Validation.Response) {
        controller?.displayDataValidation(
            Model.Validation.ViewModel(isValid: response.isValid)
        )
    }
    
    func presentRegisterResult(_ response: Model.SignUp.Response) {
        if let error = response.error {
            controller?.displayRegisterResult(
                Model.SignUp.ViewModel(
                    title: Constants.RegisterErrorTitle,
                    errorDescription: error.localizedDescription
                )
            )
        } else {
            // Нет описания и заголовка так как ошибка == nil
            controller?.displayRegisterResult(
                Model.SignUp.ViewModel(
                    title: nil,
                    errorDescription: nil
                )
            )
        }
    }
}
