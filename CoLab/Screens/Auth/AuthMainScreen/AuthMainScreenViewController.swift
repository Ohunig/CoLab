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
        
        // Logo
        static let logoName = "CoLabScreenIcon"
        static let logoHorisontalInset: CGFloat = 100
        static let logoTop: CGFloat = 250
        static let logoTitle = "Co:Lab"
        static let logoTitleFontSize: CGFloat = 48
        static let logoTitleTop: CGFloat = 16
        
        // Buttons
        static let buttonsHeight: CGFloat = 55
        static let loginButtonTitle = "Log in"
        static let signUpButtonTitle = "Sign up"
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
        // Logo
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
        
        // Logo title
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
}

// MARK: - Controller logic extension

extension AuthMainScreenViewController: AuthMainScreenControllerLogic {
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Получаем нужные цвета в виде UIColor
        let bg = viewModel.bgColor
        let bgGrad = viewModel.bgGradientColor
        let fGrad = viewModel.firstGradientColor
        let sGrad = viewModel.secondGradientColor
        
        let bgColor = UIColor(red: bg.r, green: bg.g, blue: bg.b, alpha: bg.a)
        let bgGradientColor = UIColor(red: bgGrad.r, green: bgGrad.g, blue: bgGrad.b, alpha: bgGrad.a)
        let firstGradientColor = UIColor(red: fGrad.r, green: fGrad.g, blue: fGrad.b, alpha: fGrad.a)
        let secondGradientColor = UIColor(red: sGrad.r, green: sGrad.g, blue: sGrad.b, alpha: sGrad.a)
        
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
