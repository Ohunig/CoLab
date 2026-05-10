//
//  UserInfoController.swift
//  CoLab
//
//  Created by User on 08.05.2026.
//

import UIKit

final class UserInfoController: UIViewController {
    typealias Model = UserInfoModels
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let horisontalInset: CGFloat = 22
        static let backToUnsafe: CGFloat = 30
        
        static let avatarSize: CGFloat = 170
        static let avatarTop: CGFloat = 40
        static let usernameTop: CGFloat = 10
        static let usernameFontSize: CGFloat = 40
        static let usernameLines = 2
        static let updateDuration = 0.25
        
        static let unknownUsername = "..."
        
        static let placeholderAvatar = UIImage(systemName: "person")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    private let interactor: UserInfoBusinessLogic
    
    private let backgroundView = MainBackgroundView()
    private let backButton = BackNavBarButton()
    
    private let avatarOverlay = LoadingOverlay()
    private let avatar = CircleImage(UIImage())
    private let usernameLabel = UILabel()
    private var backButtonTopConstraint: NSLayoutConstraint?
    private var modalTopSafeAreaCompensation: CGFloat = 0
    
    // MARK: Lifecycle
    
    init(interactor: UserInfoBusinessLogic) {
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        
        configureBackButton()
        configureHeader()
    }
    
    private func configureBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addAction(
            UIAction { [weak self] _ in
                self?.interactor.closeScreen()
            },
            for: .touchUpInside
        )
        view.addSubview(backButton)
        
        let topConstraint = backButton.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: -Constants.backToUnsafe + modalTopSafeAreaCompensation
        )
        backButtonTopConstraint = topConstraint
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            topConstraint
        ])
    }
    
    private func configureHeader() {
        avatarOverlay.show(over: avatar)
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatar)
        
        usernameLabel.numberOfLines = Constants.usernameLines
        usernameLabel.font = .systemFont(
            ofSize: Constants.usernameFontSize,
            weight: .medium
        )
        usernameLabel.text = Constants.unknownUsername
        usernameLabel.textAlignment = .center
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.avatarTop
            ),
            avatar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatar.heightAnchor.constraint(
                equalToConstant: Constants.avatarSize
            ),
            avatar.widthAnchor.constraint(
                equalToConstant: Constants.avatarSize
            ),
            
            usernameLabel.topAnchor.constraint(
                equalTo: avatar.bottomAnchor,
                constant: Constants.usernameTop
            ),
            usernameLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            usernameLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.horisontalInset
            )
        ])
    }
    
    private func updateAvatarImage(_ image: UIImage?) {
        avatar.image = image ?? Constants.placeholderAvatar
    }
}

// MARK: - Display logic

extension UserInfoController: UserInfoDisplayLogic {
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        let bgColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradientColor = UIColor(
            hex: viewModel.bgGradient.hex,
            alpha: viewModel.bgGradient.a
        )
        let elementsBaseColor = UIColor(
            hex: viewModel.elementsBase.hex,
            alpha: viewModel.elementsBase.a
        )
        let tintColor = UIColor(
            hex: viewModel.tint.hex,
            alpha: viewModel.tint.a
        )
        let textColor = UIColor(
            hex: viewModel.textColor.hex,
            alpha: viewModel.textColor.a
        )
        
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        
        backButton.baseColor = elementsBaseColor
        backButton.tintColor = tintColor
        
        avatar.borderColor = elementsBaseColor
        usernameLabel.textColor = textColor
    }
    
    func displayUserData(_ viewModel: Model.UserData.ViewModel) {
        if usernameLabel.window != nil {
            UIView.transition(
                with: usernameLabel,
                duration: Constants.updateDuration,
                options: .transitionCrossDissolve
            ) {
                self.usernameLabel.text = viewModel.username
            }
        } else {
            usernameLabel.text = viewModel.username
        }
        
        if viewModel.isAvatarLoading {
            if avatarOverlay.superview == nil {
                avatarOverlay.show(over: avatar)
            }
        } else {
            avatarOverlay.hide()
            updateAvatarImage(
                viewModel.avatarData.flatMap(UIImage.init(data:))
            )
        }
    }
    
    func displayError(_ viewModel: Model.ShowError.ViewModel) {
        guard presentedViewController == nil else { return }
        
        let alert = UIAlertController(
            title: viewModel.errorTitle,
            message: viewModel.errorDescription,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: viewModel.buttonText,
                style: .default
            )
        )
        present(alert, animated: true)
    }
}

extension UserInfoController: ModalTopSafeAreaCompensating {
    func setModalTopSafeAreaCompensation(_ value: CGFloat) {
        modalTopSafeAreaCompensation = value
        backButtonTopConstraint?.constant = -Constants.backToUnsafe + value
    }
}
