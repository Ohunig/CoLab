//
//  LogInPresenter.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

final class LogInPresenter: LogInPresentationLogic {
    
    private struct Constants {
        static let logInErrorTitle = "Вход не удался"
    }
    
    weak var controller: LogInControllerLogic?
    
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
    
    func presentLogInResult(_ response: Model.LogIn.Response) {
        if let error = response.error {
            controller?.displayLogInResult(
                Model.LogIn.ViewModel(
                    title: Constants.logInErrorTitle,
                    errorDescription: error.localizedDescription
                )
            )
        } else {
            // Нет описания и заголовка так как ошибка == nil
            controller?.displayLogInResult(
                Model.LogIn.ViewModel(
                    title: nil,
                    errorDescription: nil
                )
            )
        }
    }
}
