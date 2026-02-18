//
//  RegisterInteractor.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

final class RegisterInteractor: RegisterBusinessLogic {
    
    private let presenter: RegisterPresentationLogic
    
    private let colorRepository: ColorStorageLogic
    
    private let authService: AuthLogic
    
    private let router: AuthRoutingLogic
    
    // MARK: Lifecycle
    
    init(
        presenter: RegisterPresentationLogic,
        colorRepository: ColorStorageLogic,
        authService: AuthLogic,
        router: AuthRoutingLogic
    ) {
        self.presenter = presenter
        self.colorRepository = colorRepository
        self.authService = authService
        self.router = router
    }
    
    // MARK: Use-cases
    
    func loadStart() {
        presenter.presentStart(
            Model.Start.Response(
                bgColor: colorRepository.backgroundColor,
                bgGradientColor: colorRepository.backgroundGradientColor,
                firstGradientColor: colorRepository.firstGradientColor,
                secondGradientColor: colorRepository.secondGradientColor,
                elementsBaseColor: colorRepository.elementsBaseColor,
                tintColor: colorRepository.tintColor,
                textColor: colorRepository.mainTextColor
            )
        )
    }
    
    func loadAuthMainScreen() {
        router.routeToAuthMainScreen()
    }
}
