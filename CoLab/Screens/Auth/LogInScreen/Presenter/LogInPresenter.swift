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
        
        let bg = response.bgColor
        let bgGrad = response.bgGradientColor
        let fGrad = response.firstGradientColor
        let sGrad = response.secondGradientColor
        let bsColor = response.elementsBaseColor
        let tColor = response.tintColor
        let txtColor = response.textColor
        
        // Подготовка цветов для передачи
        let bgColor = (r: bg.red, g: bg.green, b: bg.blue, a: bg.alpha)
        let bgGradient = (r: bgGrad.red, g: bgGrad.green, b: bgGrad.blue, a: bgGrad.alpha)
        let firstGradient = (r: fGrad.red, g: fGrad.green, b: fGrad.blue, a: fGrad.alpha)
        let secondGradient = (r: sGrad.red, g: sGrad.green, b: sGrad.blue, a: sGrad.alpha)
        let elementsBaseColor = (r: bsColor.red, g: bsColor.green, b: bsColor.blue, a: bsColor.alpha)
        let tintColor = (r: tColor.red, g: tColor.green, b: tColor.blue, a: tColor.alpha)
        let textColor = (r: txtColor.red, g: txtColor.green, b: txtColor.blue, a: txtColor.alpha)
        
        // Запрос к контроллеру
        controller?.displayStart(
            Model.Start.ViewModel(
                bgColor: bgColor,
                bgGradientColor: bgGradient,
                firstGradientColor: firstGradient,
                secondGradientColor: secondGradient,
                elementsBaseColor: elementsBaseColor,
                tintColor: tintColor,
                textColor: textColor
            )
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
