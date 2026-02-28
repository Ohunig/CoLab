//
//  LogInViewController.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import UIKit

final class LogInViewController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        static let horisontalInset: CGFloat = 22
        
        // Заголовок
        static let title = "Вход"
        static let titleFontSize: CGFloat = 40
        
        // Кнопки
        static let buttonsHeight: CGFloat = 55
        static let buttonsBottom: CGFloat = 60
        
        static let backButtonImage = "chevron.backward"
        
        static let nextButtonBottom: CGFloat = 60
        static let nextButtonText = "Далее"
        static let enabledAlpha: CGFloat = 1
        
        // Текстовые поля
        static let fieldsHeight: CGFloat = 65
        static let fieldsSpacing: CGFloat = 21
        
        static let emailFieldImage = "envelope.fill"
        static let passwordFieldImage = "key.fill"
        
        static let emailFieldPlaceholder = "Email"
        static let passwordFieldPlaceholder = "Пароль (>5 символов)"
        
        // Объявления
        static let alertOk = "Ok"
    }
    
    private let interactor: LogInBusinessLogic
    
    lazy private var overlay = LoadingOverlay()
    
    private let backgroundView = MainBackgroundView()
    
    private let titleLabel = UILabel()
    
    private let backButton = BackNavBarButton(image: UIImage(systemName: Constants.backButtonImage) ?? UIImage())
    private let nextButton = FilledGradientButton()
    
    private let emailField = ImageTextField(image: UIImage(systemName: Constants.emailFieldImage) ?? UIImage())
    private let passwordField = ImageTextField(image: UIImage(systemName: Constants.passwordFieldImage) ?? UIImage())
    
    // MARK: Lifecycle
    
    init(interactor: LogInBusinessLogic) {
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
        configureNextButton()
        configureTextFields()
        configureNavigationBar()
    }
    
    private func configureNextButton() {
        nextButton.setTitle(Constants.nextButtonText, for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        // Обновляем состояние кнопки чтобы отображалась корректно
        validate()
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        NSLayoutConstraint.activate(
            [
                nextButton.heightAnchor.constraint(equalToConstant: Constants.buttonsHeight),
                nextButton.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: Constants.horisontalInset
                ),
                nextButton.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                ),
                nextButton.bottomAnchor.constraint(
                    equalTo: view.bottomAnchor,
                    constant: -Constants.buttonsBottom
                )
            ]
        )
    }
    
    private func configureTextFields() {
        // конфигурируем поля
        emailField.placeholder = Constants.emailFieldPlaceholder
        emailField.heightAnchor.constraint(equalToConstant: Constants.fieldsHeight).isActive = true
        
        passwordField.placeholder = Constants.passwordFieldPlaceholder
        passwordField.isSecureTextEntry = true
        passwordField.heightAnchor.constraint(equalToConstant: Constants.fieldsHeight).isActive = true
        
        emailField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        // конфигурируем стек
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(passwordField)
        stack.spacing = Constants.fieldsSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate(
            [
                stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset),
                stack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
    }
    
    private func configureNavigationBar() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem?.hidesSharedBackground = true
        
        titleLabel.text = Constants.title
        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .medium)
        navigationItem.titleView = titleLabel
    }
    
    // MARK: Button state
    
    private func validate() {
        let actualEmail = emailField.text ?? ""
        let actualPassword = passwordField.text ?? ""
        interactor.loadDataValidation(
            Model.Validation.Request(
                email: actualEmail,
                password: actualPassword
            )
        )
    }
    
    // MARK: Actions
    
    @objc
    private func textDidChange() {
        validate()
    }
    
    @objc
    private func backButtonTapped() {
        interactor.loadAuthMainScreen()
    }
    
    @objc
    private func nextButtonTapped() {
        guard let email = emailField.text, let password = passwordField.text
        else { // Если email или password - null то вызывать интерактор бессмысленно
            return
        }
        // Накладываем поверх эффект загрузки
        if let window = UIApplication.shared.currentKeyWindow {
            overlay.show(over: window)
        }
        interactor.loadLogIn(Model.LogIn.Request(email: email, password: password))
    }
}

// MARK: - Controller logic extension

extension LogInViewController: LogInControllerLogic {
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Извлекаем цвета
        let bgColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradientColor = UIColor(hex: viewModel.bgGradient.hex, alpha: viewModel.bgGradient.a)
        let firstGradientColor = UIColor(hex: viewModel.firstGradient.hex, alpha: viewModel.firstGradient.a)
        let secondGradientColor = UIColor(hex: viewModel.secondGradient.hex, alpha: viewModel.secondGradient.a)
        let elementsBaseColor = UIColor(hex: viewModel.elementsBase.hex, alpha: viewModel.elementsBase.a)
        let tintColor = UIColor(hex: viewModel.tint.hex, alpha: viewModel.tint.a)
        let textColor = UIColor(hex: viewModel.textColor.hex, alpha: viewModel.textColor.a)
        
        // Фон
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        
        // Заголовок
        titleLabel.textColor = elementsBaseColor
        
        // Кнопки
        backButton.baseColor = elementsBaseColor
        backButton.tintColor = tintColor
        
        nextButton.startColor = firstGradientColor
        nextButton.endColor = secondGradientColor
        
        // Текстовые поля
        emailField.tintColor = tintColor
        emailField.baseColor = elementsBaseColor
        emailField.textColor = textColor
        
        passwordField.tintColor = tintColor
        passwordField.baseColor = elementsBaseColor
        passwordField.textColor = textColor
    }
    
    func displayDataValidation(_ viewModel: Model.Validation.ViewModel) {
        nextButton.isEnabled = viewModel.isValid
    }
    
    func displayLogInResult(_ viewModel: Model.LogIn.ViewModel) {
        // Убираем эффект загрузки
        overlay.hide()
        
        // Если есть title или errorDescription => показываем alert с ошибкой
        if viewModel.title != nil && viewModel.errorDescription != nil {
            // Настраиваем поля корректно после обновления
            passwordField.text = ""
            validate()
            // Показываем alert
            let alert = UIAlertController(
                title: viewModel.title,
                message: viewModel.errorDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: Constants.alertOk, style: .default))
            present(alert, animated: true)
        }
    }
}
