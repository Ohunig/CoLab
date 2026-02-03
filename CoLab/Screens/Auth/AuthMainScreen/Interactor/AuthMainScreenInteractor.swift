//
//  AuthMainScreenInteractor.swift
//  CoLab
//
//  Created by User on 03.02.2026.
//

import Foundation

final class AuthMainScreenInteractor: AuthMainScreenBusinessLogic {
    
    private let presenter: AuthMainScreenPresentationLogic
    
    private let colorRepository: ColorStorageLogic
    
    // MARK: Lifecycle
    
    init(
        presenter: AuthMainScreenPresentationLogic,
        colorRepository: ColorStorageLogic
    ) {
        self.presenter = presenter
        self.colorRepository = colorRepository
    }
    
    // MARK: Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bgColor: colorRepository.backgroundColor,
                bgGradientColor: colorRepository.backgroundGradientColor,
                firstGradientColor: colorRepository.firstGradientColor,
                secondGradientColor: colorRepository.secondGradientColor
            )
        )
    }
}
