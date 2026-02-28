//
//  AuthMainScreenViewController.swift
//  CoLab
//
//  Created by User on 01.02.2026.
//

import UIKit

final class AuthMainScreenViewController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        static let horisontalInset: CGFloat = 22
        
        // Логотип
        static let logoName = "CoLabScreenIcon"
        static let logoHorisontalInset: CGFloat = 100
        static let logoTop: CGFloat = 250
        static let logoTitle = "Co:Lab"
        static let logoTitleFontSize: CGFloat = 48
        static let logoTitleTop: CGFloat = 16
        
        // Кнопки
        static let buttonsHeight: CGFloat = 55
        static let loginButtonTitle = "Вход"
        static let signUpButtonTitle = "Регистрация"
        static let buttonsInset: CGFloat = 20
        static let buttonsBottom: CGFloat = 60
        
    }
    
    private let interactor: AuthMainScreenBusinessLogic
    
    private let backgroundView = MainBackgroundView()
    private let logoTitle = UILabel()
    private let loginButton = FilledGradientButton()
    private let signUpButton = BorderGradientButton()
    
    // MARK: Lifecycle
    
    init(interactor: AuthMainScreenBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        interactor.loadStart()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        configureLogo()
        configureLogInButton()
        configureSignUpButton()
    }
    
    private func configureLogo() {
        // Логотип
        let logo = UIImage(named: Constants.logoName)
        let logoView = UIImageView(image: logo)
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)
        NSLayoutConstraint.activate(
            [
                logoView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: Constants.logoHorisontalInset
                ),
                logoView.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                ),
                logoView.topAnchor.constraint(
                    equalTo: view.topAnchor,
                    constant: Constants.logoTop
                )
            ]
        )
        
        // Заголовок логотипа
        logoTitle.text = Constants.logoTitle
        logoTitle.font = .systemFont(
            ofSize: Constants.logoTitleFontSize,
            weight: .medium
        )
        logoTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoTitle)
        NSLayoutConstraint.activate(
            [
                logoTitle.topAnchor.constraint(
                    equalTo: logoView.bottomAnchor,
                    constant: Constants.logoTitleTop
                ),
                logoTitle.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                )
            ]
        )
    }
    
    private func configureLogInButton() {
        loginButton.setTitle(Constants.loginButtonTitle, for: .normal)
        loginButton.addTarget(self, action: #selector(logInTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        NSLayoutConstraint.activate(
            [
                loginButton.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight),
                loginButton.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: Constants.horisontalInset
                ),
                loginButton.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                )
            ]
        )
    }
    
    private func configureSignUpButton() {
        signUpButton.setTitle(Constants.signUpButtonTitle, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signUpButton)
        NSLayoutConstraint.activate(
            [
                signUpButton.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight),
                signUpButton.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: Constants.horisontalInset
                ),
                signUpButton.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                ),
                signUpButton.topAnchor.constraint(
                    equalTo: loginButton.bottomAnchor,
                    constant: Constants.buttonsInset
                ),
                signUpButton.bottomAnchor.constraint(
                    equalTo: view.bottomAnchor,
                    constant: -Constants.buttonsBottom
                )
            ]
        )
    }
    
    // MARK: Buttons targets
    
    @objc
    private func logInTapped() {
        interactor.loadLogInScreen()
    }
    
    @objc
    private func signUpTapped() {
        interactor.loadRegisterScreen()
    }
}

// MARK: - Controller logic extension

extension AuthMainScreenViewController: AuthMainScreenControllerLogic {
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Извлекаем цвета
        let bgColor = UIColor(hex: viewModel.bgColor.hex, alpha: viewModel.bgColor.a)
        let bgGradientColor = UIColor(hex: viewModel.bgGradientColor.hex, alpha: viewModel.firstGradientColor.a)
        let firstGradientColor = UIColor(hex: viewModel.firstGradientColor.hex, alpha: viewModel.firstGradientColor.a)
        let secondGradientColor = UIColor(hex: viewModel.secondGradientColor.hex, alpha: viewModel.secondGradientColor.a)
        
        // Фон
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        // Лого
        logoTitle.textColor = secondGradientColor
        // Кнопки
        loginButton.startColor = firstGradientColor
        loginButton.endColor = secondGradientColor
        signUpButton.startColor = firstGradientColor
        signUpButton.endColor = secondGradientColor
        signUpButton.setTitleColor(secondGradientColor, for: .normal)
    }
}
