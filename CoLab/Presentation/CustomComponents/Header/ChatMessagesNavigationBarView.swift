//
//  ChatMessagesNavigationBarView.swift
//  CoLab
//
//  Created by User on 01.04.2026.
//

import UIKit

final class ChatMessagesNavigationBarView: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let titleFontSize: CGFloat = 22
        static let titleHorizontalInset: CGFloat = 18
        static let titleIslandCornerRadius: CGFloat = 22
        static let titleIslandBorderWidth: CGFloat = 1
        
        static let itemGap: CGFloat = 12
        static let titleLines = 1
        
        static let avatarTransitionDuration: TimeInterval = 0.25
        
        static let placeholderAvatar = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    private let backButton = BackNavBarButton()
    private let titleIslandView = UIView()
    private let titleLabel = UILabel()
    private let avatarView = CircleImage(Constants.placeholderAvatar)
    private let avatarOverlay = LoadingOverlay()
    
    var onBackTap: (() -> Void)?
    var onAvatarTap: (() -> Void)?
    
    // MARK: Content
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    // MARK: Colors
    
    var controlsBaseColor: UIColor? {
        didSet {
            backButton.baseColor = controlsBaseColor
            avatarView.borderColor = controlsBaseColor
        }
    }
    
    var titleIslandFillColor: UIColor? {
        didSet {
            titleIslandView.backgroundColor = titleIslandFillColor
        }
    }
    
    var titleIslandBorderColor: UIColor? {
        didSet {
            titleIslandView.layer.borderColor = titleIslandBorderColor?.cgColor
        }
    }
    
    var textColor: UIColor? {
        didSet {
            backButton.tintColor = textColor
            titleLabel.textColor = textColor
        }
    }
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    // MARK: Public
    
    func setAvatarImage(_ image: UIImage?, animated: Bool) {
        let resolvedImage = image ?? Constants.placeholderAvatar
        avatarOverlay.hide()
        
        let updateAvatar = {
            self.avatarView.image = resolvedImage
        }
        
        guard animated, avatarView.window != nil else {
            updateAvatar()
            return
        }
        
        UIView.transition(
            with: avatarView,
            duration: Constants.avatarTransitionDuration,
            options: .transitionCrossDissolve
        ) {
            updateAvatar()
        }
    }
    
    func showAvatarLoading() {
        guard avatarOverlay.superview == nil else { return }
        avatarOverlay.isUserInteractionEnabled = false
        avatarOverlay.show(over: avatarView)
    }
    
    func hideAvatarLoading() {
        avatarOverlay.hide()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        backgroundColor = .clear
        
        configureBackButton()
        configureTitleIsland()
        configureAvatarView()
        configureLayout()
    }
    
    private func configureBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addAction(
            UIAction { [weak self] _ in
                self?.onBackTap?()
            },
            for: .touchUpInside
        )
        addSubview(backButton)
    }
    
    private func configureTitleIsland() {
        titleIslandView.translatesAutoresizingMaskIntoConstraints = false
        titleIslandView.layer.cornerRadius = Constants.titleIslandCornerRadius
        titleIslandView.layer.borderWidth = Constants.titleIslandBorderWidth
        titleIslandView.clipsToBounds = true
        addSubview(titleIslandView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(
            ofSize: Constants.titleFontSize,
            weight: .medium
        )
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = Constants.titleLines
        titleLabel.lineBreakMode = .byTruncatingTail
        titleIslandView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: titleIslandView.leadingAnchor,
                constant: Constants.titleHorizontalInset
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: titleIslandView.trailingAnchor,
                constant: -Constants.titleHorizontalInset
            ),
            titleLabel.centerYAnchor.constraint(equalTo: titleIslandView.centerYAnchor)
        ])
    }
    
    private func configureAvatarView() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleAvatarTap)
            )
        )
        addSubview(avatarView)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            backButton.topAnchor.constraint(equalTo: topAnchor),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),
            
            avatarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarView.topAnchor.constraint(equalTo: topAnchor),
            avatarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor),
            
            // Центральный островок подстраивается под title, но не может
            // залезть на кнопки слева и справа.
            titleIslandView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleIslandView.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleIslandView.heightAnchor.constraint(equalTo: heightAnchor),
            titleIslandView.leadingAnchor.constraint(
                greaterThanOrEqualTo: backButton.trailingAnchor,
                constant: Constants.itemGap
            ),
            titleIslandView.trailingAnchor.constraint(
                lessThanOrEqualTo: avatarView.leadingAnchor,
                constant: -Constants.itemGap
            )
        ])
    }
    
    // MARK: Actions
    
    @objc
    private func handleAvatarTap() {
        onAvatarTap?()
    }
}
