//
//  AuthMainScreenPresenter.swift
//  CoLab
//
//  Created by User on 03.02.2026.
//

import Foundation

final class AuthMainScreenPresenter: AuthMainScreenPresentationLogic {
    
    weak var controller: AuthMainScreenControllerLogic?
    
    // MARK: Present
    
    func presentStart(_ response: Model.Start.Response) {
        
        let bg = response.bgColor
        let bgGrad = response.bgGradientColor
        let fGrad = response.firstGradientColor
        let sGrad = response.secondGradientColor
        
        // Подготовка цветов для передачи
        let bgColor = (r: bg.red, g: bg.green, b: bg.blue, a: bg.alpha)
        let bgGradient = (r: bgGrad.red, g: bgGrad.green, b: bgGrad.blue, a: bgGrad.alpha)
        let firstGradient = (r: fGrad.red, g: fGrad.green, b: fGrad.blue, a: fGrad.alpha)
        let secondGradient = (r: sGrad.red, g: sGrad.green, b: sGrad.blue, a: sGrad.alpha)
        
        // Запрос к контроллеру
        controller?.displayStart(
            Model.Start.ViewModel(
                bgColor: bgColor,
                bgGradientColor: bgGradient,
                firstGradientColor: firstGradient,
                secondGradientColor: secondGradient
            )
        )
    }
}
