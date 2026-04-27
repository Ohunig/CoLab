//
//  UserSettingsController.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation
import UIKit

final class UserSettingsController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let horisontalInset: CGFloat = 22
        
        // Распологаем элементы навигации выше
        static let backToUnsafe: CGFloat = 30
        
        static let avatarSize: CGFloat = 170
        static let avatarTop: CGFloat = 40
        static let avatarGap: CGFloat = 10
        static let avatarLabelFontSize: CGFloat = 40
        static let avatarLabelLines = 1
        static let userDuration = 0.25
        
        static let unknownUsername = "..."
        
        static let cellsHeight: CGFloat = 80
        static let stackTop: CGFloat = 55
        static let changeInfoText = "Изменить информацию"
        static let logOutText = "Выйти из аккаунта"
        
        static let stackGap: CGFloat = 20
    }
    
    private let interactor: UserSettingsBusinessLogic
    
    private let backgroundView = MainBackgroundView()
    
    private let logo = CoLabLogo()
    
    private let avatarOverlay = LoadingOverlay()
    private let avatar = CircleImage(UIImage())
    private let username = UILabel()
    
    private let changeInfoCell = ItemCell()
    private let logoutCell = ItemCell()
    
    // MARK: Lifecycle
    
    init(interactor: UserSettingsBusinessLogic) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Стартуем слушатель до показа экрана, чтобы аватар начал подтягиваться раньше
        interactor.listenUserData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        interactor.stopListeningUserData()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        
        configureLogo()
        configureAvatarWithTitle()
        configureCells()
    }
    
    private func configureLogo() {
        logo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logo)
        NSLayoutConstraint.activate(
            [
                logo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset),
                logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -Constants.backToUnsafe)
            ]
        )
    }
    
    private func configureAvatarWithTitle() {
        avatarOverlay.show(over: avatar)
        
        username.numberOfLines = Constants.avatarLabelLines
        username.font = .systemFont(ofSize: Constants.avatarLabelFontSize, weight: .medium)
        username.text = Constants.unknownUsername
        username.textAlignment = .center
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        username.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatar)
        view.addSubview(username)
        
        NSLayoutConstraint.activate(
            [
                avatar.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
                avatar.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
                avatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.avatarTop),
                avatar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                username.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: Constants.avatarGap),
                username.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset),
                username.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
    }
    
    private func configureCells() {
        // Настройка ячеек
        
        changeInfoCell.addAction(
            UIAction { [weak self] _ in
                self?.interactor.loadChangeDataScreen()
            },
            for: .touchUpInside)
        changeInfoCell.text = Constants.changeInfoText
        changeInfoCell.translatesAutoresizingMaskIntoConstraints = false
        
        logoutCell.addAction(
            UIAction { [weak self] _ in
                self?.interactor.logOut()
            },
            for: .touchUpInside)
        logoutCell.text = Constants.logOutText
        logoutCell.textColor = .red
        logoutCell.tintColor = .red
        logoutCell.translatesAutoresizingMaskIntoConstraints = false
        
        // Настройка стека
        let stack = UIStackView(arrangedSubviews: [changeInfoCell, logoutCell])
        stack.axis = .vertical
        stack.spacing = Constants.stackGap
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate(
            [
                logoutCell.heightAnchor.constraint(equalToConstant: Constants.cellsHeight),
                changeInfoCell.heightAnchor.constraint(equalToConstant: Constants.cellsHeight),
                
                stack.topAnchor.constraint(equalTo: username.bottomAnchor, constant: Constants.stackTop),
                stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset),
                stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ]
        )
    }
}

// MARK: - Display logic extension

extension UserSettingsController: UserSettingsDisplayLogic {
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Получаем нужные цвета в виде UIColor
        let bgColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradientColor = UIColor(hex: viewModel.bgGradient.hex, alpha: viewModel.bgGradient.a)
        let elementsBaseColor = UIColor(hex: viewModel.elementsBase.hex, alpha: viewModel.elementsBase.a)
        let tintColor = UIColor(hex: viewModel.tint.hex, alpha: viewModel.tint.a)
        let textColor = UIColor(hex: viewModel.textColor.hex, alpha: viewModel.textColor.a)
        
        // Фон
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        
        // Лого
        logo.baseColor = elementsBaseColor
        logo.textColor = textColor
        
        // Аватар + юзернейм
        avatar.borderColor = elementsBaseColor
        username.textColor = textColor
        
        // Ячейки
        changeInfoCell.baseColor = elementsBaseColor
        changeInfoCell.tintColor = tintColor
        changeInfoCell.textColor = textColor
        
        logoutCell.baseColor = elementsBaseColor
    }
    
    func displayUserChanges(_ viewModel: Model.GetUserData.ViewModel) {
        // Так как если window == nil то при transition могут быть видны артефакты
        if username.window != nil {
            UIView.transition(
                with: username,
                duration: Constants.userDuration,
                options: .transitionCrossDissolve
            ) {
                self.username.text = viewModel.username
            }
        } else {
            username.text = viewModel.username
        }
        
        avatarOverlay.hide()
        // Нет смысла менять аватар если он пустой или не менялся
        guard let avatarData = viewModel.avatarData else { return }
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
    
    func displayError(_ viewModel: Model.ShowError.ViewModel) {
        // Показываем alert
        let alert = UIAlertController(
            title: viewModel.errorTitle,
            message: viewModel.errorDescription,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: viewModel.errorTitle,
                style: .default
            )
        )
        present(alert, animated: true)
    }
}
