//
//  ChatMessagesNavigationBarView.swift
//  CoLab
//
//  Created by OpenAI on 26.03.2026.
//

import UIKit

final class ChatMessagesNavigationBarView: UIView {
    
    private struct Constants {
        static let avatarTransitionDuration: TimeInterval = 0.25
        static let titleFontSize: CGFloat = 22
        static let itemGap: CGFloat = 12
        static let titleLines = 1
        
        static let placeholderAvatar = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    private let backButton = BackNavBarButton()
    private let titleLabel = UILabel()
    private let avatarView = CircleImage(Constants.placeholderAvatar)
    private let avatarOverlay = LoadingOverlay()
    
    var onBackTap: (() -> Void)?
    
    // MARK: Colors
    
    var baseColor: UIColor? {
        didSet {
            backButton.baseColor = baseColor
            avatarView.baseColor = baseColor
        }
    }
    
    var textColor: UIColor? {
        didSet {
            backButton.tintColor = textColor
            titleLabel.textColor = textColor
        }
    }
    
    // MARK: Lifecycle
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public
    
    func setAvatarImage(_ image: UIImage?, animated: Bool) {
        let resolvedImage = image ?? Constants.placeholderAvatar
        avatarOverlay.hide()
        
        let applyImage = {
            self.avatarView.image = resolvedImage
        }
        
        guard animated, avatarView.window != nil else {
            applyImage()
            return
        }
        
        UIView.transition(
            with: avatarView,
            duration: Constants.avatarTransitionDuration,
            options: .transitionCrossDissolve
        ) {
            applyImage()
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
        configureTitleLabel()
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
    
    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(
            ofSize: Constants.titleFontSize,
            weight: .medium
        )
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = Constants.titleLines
        addSubview(titleLabel)
    }
    
    private func configureAvatarView() {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
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
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: backButton.trailingAnchor,
                constant: Constants.itemGap
            ),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: avatarView.leadingAnchor,
                constant: -Constants.itemGap
            )
        ])
    }
}
