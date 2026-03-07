//
//  LogInInteractor.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

final class LogInInteractor: LogInBusinessLogic {
    
    private struct Constants {
        static let minPasswordSymbols = 6
        static let mailMustIncludeAtSymbol = "@"
    }
    
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
                bg: colorRepository.backgroundColor,
                bgGradient: colorRepository.backgroundGradientColor,
                firstGradient: colorRepository.firstGradientColor,
                secondGradient: colorRepository.secondGradientColor,
                elementsBase: colorRepository.elementsBaseColor,
                tint: colorRepository.tintColor,
                textColor: colorRepository.mainTextColor
            )
        )
    }
    
    func loadDataValidation(_ request: Model.Validation.Request) {
        let isValid = request.password.count >= Constants.minPasswordSymbols && request.email.contains(Constants.mailMustIncludeAtSymbol)
        presenter.presentDataValidation(Model.Validation.Response(isValid: isValid))
    }
    
    func loadLogIn(_ request: Model.LogIn.Request) {
        // Считаем, что пришли корректные по некоторым критериям данные
        authService.logIn(email: request.email, password: request.password) { [weak self] result in
            // Так как не знаем где будет исполняться этот completion
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.presenter.presentLogInResult(Model.LogIn.Response(error: nil))
                    self?.router.routeToMainScreens()
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
