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
                    self?.loadAuthMainScreen()
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
