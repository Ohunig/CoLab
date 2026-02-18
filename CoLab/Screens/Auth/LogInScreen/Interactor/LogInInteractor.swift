//
//  LogInInteractor.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

final class LogInInteractor: LogInBusinessLogic {
    
    private let presenter: LogInPresentationLogic
    
    private let colorRepository: ColorStorageLogic
    
    private let authService: AuthLogic
    
    private let router: AuthRoutingLogic
    
    // MARK: Lifecycle
    
    init(
        presenter: LogInPresentationLogic,
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
    
    func loadLogIn(_ request: Model.LogIn.Request) {
        // Считаем, что пришли корректные по некоторым критериям данные
        authService.logIn(email: request.email, password: request.password) { [weak self] result in
            // Так как не знаем где будет исполняться этот completion
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.presenter.presentLogInResult(Model.LogIn.Response(error: nil))
                    self?.loadAuthMainScreen()
                case .failure(let error):
                    self?.presenter.presentLogInResult(Model.LogIn.Response(error: error))
                }
            }
        }
    }
    
    func loadAuthMainScreen() {
        router.routeToAuthMainScreen()
    }
}
