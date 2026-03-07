//
//  RegisterInteractor.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

final class RegisterInteractor: RegisterBusinessLogic {
    
    private struct Constants {
        static let minUsernameSymbols = 4
        static let minPasswordSymbols = 6
        static let mailMustIncludeAtSymbol = "@"
    }
    
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
        let isValid = request.password.count >= Constants.minPasswordSymbols && request.email.contains(Constants.mailMustIncludeAtSymbol) && request.username.count >= Constants.minUsernameSymbols
        presenter.presentDataValidation(Model.Validation.Response(isValid: isValid))
    }
    
    func loadRegister(request: Model.SignUp.Request) {
        authService.signUp(
            email: request.email,
            username: request.username,
            password: request.password
        ) { [weak self] result in
            // Так как не знаем на каком потоке будет исполняться
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.presenter.presentRegisterResult(
                        Model.SignUp.Response(error: nil)
                    )
                    self?.router.routeToMainScreens()
                case .failure(let error):
                    self?.presenter.presentRegisterResult(
                        Model.SignUp.Response(error: error)
                    )
                }
            }
        }
    }
    
    func loadAuthMainScreen() {
        router.routeToAuthMainScreen()
    }
}
