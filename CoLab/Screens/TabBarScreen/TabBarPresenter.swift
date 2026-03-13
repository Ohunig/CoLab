//
//  TabBarPresenter.swift
//  CoLab
//
//  Created by User on 07.03.2026.
//

import Foundation

final class TabBarPresenter: TabBarPresentationLogic {
    
    weak var controller: TabBarDisplayLogic?
    
    // MARK: Present
    
    func presentStart(_ response: Model.Start.Response) {
        controller?.displayStart(
            Model.Start.ViewModel(
                firstGradient: (hex: response.firstGradient.hex, a: response.firstGradient.alpha),
                secondGradient: (hex: response.secondGradient.hex, a: response.secondGradient.alpha),
                buttonsColor: (hex: response.buttonsColor.hex, a: response.buttonsColor.alpha),
                wrapperColor: (hex: response.wrapperColor.hex, a: response.wrapperColor.alpha)
            )
        )
    }
}
