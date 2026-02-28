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
        controller?.displayStart(
            Model.Start.ViewModel(
                bgColor: (hex: response.bgColor.hex, a: response.bgColor.alpha),
                bgGradientColor: (hex: response.bgGradientColor.hex, a: response.bgGradientColor.alpha),
                firstGradientColor: (hex: response.firstGradientColor.hex, a: response.firstGradientColor.alpha),
                secondGradientColor: (hex: response.secondGradientColor.hex, a: response.secondGradientColor.alpha)
            )
        )
    }
}
