//
//  RegisterViewController.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import UIKit

final class RegisterViewController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        static let horisontalInset: CGFloat = 22
        
        // Заголовок
        static let title = "Регистрация"
        static let titleFontSize: CGFloat = 36
        
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
        
        static let usernameFieldImage = "person.fill"
        static let emailFieldImage = "envelope.fill"
        static let passwordFieldImage = "key.fill"
        
        static let emailFieldPlaceholder = "Email"
        static let passwordFieldPlaceholder = "Пароль (>5 символов)"
        static let usernameFieldPlaceholder = "Имя аккаунта"
        
        // Параметры введённых значений
        static let minPasswordSymbols = 6
        static let minUsernameSymbols = 4
        
        // Объявления
        static let alertOk = "Ok"
    }
    
    private let interactor: RegisterBusinessLogic
    
    lazy private var overlay = LoadingOverlay()
    
    private let backgroundView = MainBackgroundView()
    
    private let titleLabel = UILabel()
    
    private let backButton = BackNavBarButton(image: UIImage(systemName: Constants.backButtonImage) ?? UIImage())
    private let nextButton = FilledGradientButton()
    
    private let usernameField = ImageTextField(image: UIImage(systemName: Constants.usernameFieldImage) ?? UIImage())
    private let emailField = ImageTextField(image: UIImage(systemName: Constants.emailFieldImage) ?? UIImage())
    private let passwordField = ImageTextField(image: UIImage(systemName: Constants.passwordFieldImage) ?? UIImage())
    
    // MARK: Lifecycle
    
    init(interactor: RegisterBusinessLogic) {
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
        updateNextButtonState()
        
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
        passwordField.heightAnchor.constraint(equalToConstant: Constants.fieldsHeight).isActive = true
        passwordField.isSecureTextEntry = true
        
        usernameField.placeholder = Constants.usernameFieldPlaceholder
        usernameField.heightAnchor.constraint(equalToConstant: Constants.fieldsHeight).isActive = true
        
        emailField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        // конфигурируем стек
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(usernameField)
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
    
    private func updateNextButtonState() {
        let actualEmail = emailField.text ?? ""
        let actualPassword = passwordField.text ?? ""
        let actualUsername = usernameField.text ?? ""
        
        // Первичная проверка валидности введённых данных
        let valid = actualEmail.contains("@") && actualPassword.count >= Constants.minPasswordSymbols && actualUsername.count >= Constants.minUsernameSymbols
        
        // Изменяем состояние кнопки в зависимости от корректности данных
        nextButton.isEnabled = valid
    }
    
    // MARK: Actions
    
    @objc
    private func textDidChange() {
        updateNextButtonState()
    }
    
    @objc
    private func backButtonTapped() {
        interactor.loadAuthMainScreen()
    }
    
    @objc
    private func nextButtonTapped() {
        guard let email = emailField.text,
              let password = passwordField.text,
              let username = usernameField.text
        else {
            // Вызывать интерактор бессмысленно
            return
        }
        
        // Очищаем поле с паролем
        passwordField.text = ""
        textDidChange()
        // Накладываем поверх эффект загрузки
        if let window = UIApplication.shared.currentKeyWindow {
            overlay.show(over: window)
        }
        
        interactor.loadRegister(
            request: Model.SignUp.Request(
                email: email,
                password: password,
                username: username
            )
        )
    }
}

// MARK: - Controller logic extension

extension RegisterViewController: RegisterControllerLogic {
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Получаем нужные цвета в виде UIColor
        let bg = viewModel.bgColor
        let bgGrad = viewModel.bgGradientColor
        let fGrad = viewModel.firstGradientColor
        let sGrad = viewModel.secondGradientColor
        let bsColor = viewModel.elementsBaseColor
        let tColor = viewModel.tintColor
        let txtColor = viewModel.textColor
        
        let bgColor = UIColor(red: bg.r, green: bg.g, blue: bg.b, alpha: bg.a)
        let bgGradientColor = UIColor(red: bgGrad.r, green: bgGrad.g, blue: bgGrad.b, alpha: bgGrad.a)
        let firstGradientColor = UIColor(red: fGrad.r, green: fGrad.g, blue: fGrad.b, alpha: fGrad.a)
        let secondGradientColor = UIColor(red: sGrad.r, green: sGrad.g, blue: sGrad.b, alpha: sGrad.a)
        let elementsBaseColor = UIColor(red: bsColor.r, green: bsColor.g, blue: bsColor.b, alpha: bsColor.a)
        let tintColor = UIColor(red: tColor.r, green: tColor.g, blue: tColor.b, alpha: tColor.a)
        let textColor = UIColor(red: txtColor.r, green: txtColor.g, blue: txtColor.b, alpha: txtColor.a)
        
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
        
        usernameField.tintColor = tintColor
        usernameField.baseColor = elementsBaseColor
        usernameField.textColor = textColor
    }
    
    func displayRegisterResult(_ viewModel: Model.SignUp.ViewModel) {
        // Убираем эффект загрузки
        overlay.hide()
        
        // Если есть title или errorDescription => показываем alert с ошибкой
        if viewModel.title != nil && viewModel.errorDescription != nil {
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
