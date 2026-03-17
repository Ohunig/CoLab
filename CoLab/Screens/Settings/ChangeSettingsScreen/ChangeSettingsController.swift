//
//  ChangeSettingsController.swift
//  CoLab
//
//  Created by User on 16.03.2026.
//

import Foundation
import UIKit

final class ChangeSettingsController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let horisontalInset: CGFloat = 22
        
        // Распологаем элементы навигации выше
        static let backToUnsafe: CGFloat = 40
        
        static let avatarSize: CGFloat = 170
        static let avatarTop: CGFloat = 40
        static let avatarGap: CGFloat = 20
        static let userDuration = 0.25
        
        static let usernameFieldImage = "person.fill"
        static let usernameFieldPlaceholder = "Введите никнейм"
        static let usernameFieldHeight: CGFloat = 65
        static let unknownUsername = "..."
        
        static let nextButtonText = "Обновить"
        static let buttonsHeight: CGFloat = 55
        static let buttonsBottom: CGFloat = 60
        
        static let photoCompressionQuality: CGFloat = 0.2
        
        static let alertOk = "Ok"
    }
    
    private let interactor: ChangeSettingsBusinessLogic
    
    private let overlay = LoadingOverlay()
    private let backgroundView = MainBackgroundView()
    
    private let backButton = BackNavBarButton()
    
    private let avatarOverlay = LoadingOverlay()
    private let avatar = CircleImage(UIImage())
    
    // Если пользователь не менял аватар на экране — не загружаем его заново
    private var isAvatarChanged = false
    
    private let usernameField = ImageTextField(
        image: UIImage(
            systemName: Constants.usernameFieldImage
        )
    )
    
    private let nextButton = FilledGradientButton()
    
    // MARK: Lifecycle
    
    init(interactor: ChangeSettingsBusinessLogic) {
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
        interactor.loadUserData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avatarOverlay.hide()
        overlay.hide()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        
        configureBackButton()
        configureAvatar()
        configureUsernameField()
        configureNextButton()
    }
    
    private func configureBackButton() {
        // Назначаем действие кнопке
        backButton.addAction(
            UIAction { [weak self]_ in
                self?.interactor.loadGoBack()
            },
            for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        NSLayoutConstraint.activate(
            [
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -Constants.backToUnsafe),
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset)
            ]
        )
    }
    
    private func configureAvatar() {
        avatarOverlay.show(over: avatar)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatar)
        
        NSLayoutConstraint.activate(
            [
                avatar.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
                avatar.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
                avatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.avatarTop),
                avatar.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
    }
    
    private func configureUsernameField() {
        usernameField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameField.text = Constants.unknownUsername
        usernameField.placeholder = Constants.usernameFieldPlaceholder
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameField)
        
        NSLayoutConstraint.activate(
            [
                usernameField.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: Constants.avatarGap),
                usernameField.heightAnchor.constraint(equalToConstant: Constants.usernameFieldHeight),
                usernameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset),
                usernameField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
    }
    
    private func configureNextButton() {
        nextButton.setTitle(Constants.nextButtonText, for: .normal)
        nextButton.isEnabled = false
        nextButton.addAction(
            UIAction { [weak self] _ in
                self?.nextButtonTapped()
            },
            for: .touchUpInside
        )
        
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
    
    // MARK: Validate
    
    private func validate() {
        let actualUsername = usernameField.text ?? ""
        interactor.loadDataValidation(
            Model.Validation.Request(
                username: actualUsername
            )
        )
    }
    
    // MARK: Actions
    
    private func nextButtonTapped() {
        guard let username = usernameField.text else { return }
        
        let imageData = isAvatarChanged
        ? avatar.image?.jpegData(compressionQuality: Constants.photoCompressionQuality)
        : nil
        
        // Накладываем поверх эффект загрузки
        if let window = UIApplication.shared.currentKeyWindow {
            overlay.show(over: window)
        }
        
        interactor.updateUserData(
            Model.UpdateUserData.Request(
                username: username,
                avatarData: imageData
            )
        )
    }
    
    @objc
    private func textDidChange() {
        validate()
    }
}

// MARK: - Display logic extension

extension ChangeSettingsController: ChangeSettingsDisplayLogic {
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Получаем нужные цвета в виде UIColor
        let bgColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradientColor = UIColor(hex: viewModel.bgGradient.hex, alpha: viewModel.bgGradient.a)
        let firstGradient = UIColor(hex: viewModel.firstGradient.hex, alpha: viewModel.firstGradient.a)
        let secondGradient = UIColor(hex: viewModel.secondGradient.hex, alpha: viewModel.secondGradient.a)
        let elementsBaseColor = UIColor(hex: viewModel.elementsBase.hex, alpha: viewModel.elementsBase.a)
        let tintColor = UIColor(hex: viewModel.tint.hex, alpha: viewModel.tint.a)
        let textColor = UIColor(hex: viewModel.textColor.hex, alpha: viewModel.textColor.a)
        
        // Фон
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        
        // Аватар
        avatar.baseColor = elementsBaseColor
        
        // Юзернейм
        usernameField.baseColor = elementsBaseColor
        usernameField.textColor = textColor
        usernameField.tintColor = tintColor
        
        // Кнопки
        backButton.baseColor = elementsBaseColor
        backButton.tintColor = tintColor
        
        nextButton.startColor = firstGradient
        nextButton.endColor = secondGradient
    }
    
    func displayUserData(_ viewModel: Model.GetUserData.ViewModel) {
        // Так как если window == nil то при transition могут быть видны артефакты
        if usernameField.window != nil {
            UIView.transition(
                with: usernameField,
                duration: Constants.userDuration,
                options: .transitionCrossDissolve
            ) {
                self.usernameField.text = viewModel.username
            }
        } else {
            usernameField.text = viewModel.username
        }
        
        validate()
        
        // Нет смысла менять аватар если он пустой или не менялся. Также не отключаем оверлей
        guard let avatarData = viewModel.avatarData else { return }
        avatarOverlay.hide()
        isAvatarChanged = false
        // Так как если window == nil то при transition могут быть видны артефакты
        if avatar.window != nil {
            UIView.transition(
                with: avatar,
                duration: Constants.userDuration,
                options: .transitionCrossDissolve
            ) {
                self.avatar.image = UIImage(data: avatarData)
            }
        } else {
            avatar.image = UIImage(data: avatarData)
        }
    }
    
    // MARK: Display validation
    
    func displayDataValidation(_ viewModel: Model.Validation.ViewModel) {
        nextButton.isEnabled = viewModel.isValid
    }
    
    // MARK: Display update result
    
    func displayUpdateDataResult(_ viewModel: Model.CatchError.ViewModel) {
        overlay.hide()
        
        let alert = UIAlertController(
            title: viewModel.errorTitle,
            message: viewModel.errorDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.alertOk, style: .default))
        present(alert, animated: true)
    }
}
