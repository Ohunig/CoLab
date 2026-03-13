//
//  UserSettingsPresenter.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation

final class UserSettingsPresenter: UserSettingsPresentationLogic {
    
    weak var controller: UserSettingsDisplayLogic?
    
    // MARK: Present
    
    func presentStart(_ response: Model.Start.Response) {
        controller?.displayStart(
            Model.Start.ViewModel(
                bg: (hex: response.bg.hex, a: response.bg.alpha),
                bgGradient: (hex: response.bgGradient.hex, a: response.bgGradient.alpha),
                elementsBase: (hex: response.elementsBase.hex, a: response.elementsBase.alpha),
                tint: (hex: response.tint.hex, a: response.tint.alpha),
                textColor: (hex: response.textColor.hex, a: response.textColor.alpha)
            )
        )
    }
}
