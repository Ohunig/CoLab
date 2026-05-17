//
//  TaskItemCell.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import UIKit

final class TaskItemCell: UITableViewCell {
    
    private struct Constants {
        static let reuseIdentifier = "TaskItemCell"
        static let fatalError = "init(coder:) has not been implemented"
        static let animateDuration: CGFloat = 0.06
        static let standardAlpha: CGFloat = 1
        static let tappedAlpha: CGFloat = 0.5
        
        static let verticalInset: CGFloat = 6
        static let innerInset: CGFloat = 16
        static let containerCornerRadius: CGFloat = 25
        static let containerBorderWidth: CGFloat = 1
        static let activeAlpha: CGFloat = 0.5
        static let completedAlpha: CGFloat = 0.24
        static let completedTextAlpha: CGFloat = 0.62
        static let disabledAlpha: CGFloat = 0.42
        
        static let titleFontSize: CGFloat = 18
        static let voteButtonText = "Голосовать"
        static let voteButtonFontSize: CGFloat = 15
        static let voteButtonWidth: CGFloat = 112
        static let voteButtonHeight: CGFloat = 38
        static let voteButtonCornerRadius: CGFloat = 19
        static let voteButtonBorderWidth: CGFloat = 1
        static let titleToButtonSpacing: CGFloat = 12
    }
    
    static let reuseIdentifier = Constants.reuseIdentifier
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let voteButton = UIButton(type: .system)
    
    private var base: UIColor?
    private var labelColor: UIColor?
    private var isCompletedValue = false
    private var isVoteButtonVisibleValue = true
    private var isVoteButtonEnabledValue = true
    private var isPressed = false
    private var titleToButtonConstraint: NSLayoutConstraint?
    private var titleToContainerConstraint: NSLayoutConstraint?
    
    var onVoteTap: (() -> Void)?
    
    var baseColor: UIColor? {
        get { base }
        set {
            base = newValue
            containerView.layer.borderColor = newValue?.cgColor
            updateColors()
        }
    }
    
    var textColor: UIColor? {
        get { labelColor }
        set {
            labelColor = newValue
            updateColors()
        }
    }
    
    var title: String {
        get { titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }
    
    var isCompletedTask: Bool {
        get { isCompletedValue }
        set {
            isCompletedValue = newValue
            isVoteButtonVisible = !newValue
            updateColors()
        }
    }
    
    var isVoteButtonVisible: Bool {
        get { isVoteButtonVisibleValue }
        set {
            isVoteButtonVisibleValue = newValue
            updateVoteButtonVisibility()
            updateColors()
        }
    }
    
    var isVoteButtonEnabled: Bool {
        get { isVoteButtonEnabledValue }
        set {
            isVoteButtonEnabledValue = newValue
            voteButton.isEnabled = newValue
            updatePressedState(isPressed: isPressed, animated: false)
            updateColors()
        }
    }
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title = ""
        isCompletedTask = false
        isVoteButtonVisible = true
        isVoteButtonEnabled = true
        onVoteTap = nil
        updatePressedState(isPressed: false, animated: false)
    }
    
    // MARK: Highlight
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updatePressedState(isPressed: highlighted, animated: animated)
    }
    
    private func updatePressedState(isPressed: Bool, animated: Bool) {
        self.isPressed = isPressed
        let changes = {
            if !self.isVoteButtonEnabledValue && self.isVoteButtonVisibleValue {
                self.containerView.alpha = Constants.disabledAlpha
            } else {
                self.containerView.alpha = isPressed
                    ? Constants.tappedAlpha
                    : Constants.standardAlpha
            }
        }
        
        guard animated else {
            changes()
            return
        }
        
        UIView.animate(withDuration: Constants.animateDuration) {
            changes()
        }
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        updatePressedState(isPressed: false, animated: false)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = Constants.containerCornerRadius
        containerView.layer.borderWidth = Constants.containerBorderWidth
        contentView.addSubview(containerView)
        
        titleLabel.font = .systemFont(
            ofSize: Constants.titleFontSize,
            weight: .medium
        )
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        configureVoteButton()
        
        configureLayout()
        baseColor = .white
        textColor = .white
    }
    
    private func configureVoteButton() {
        voteButton.setTitle(Constants.voteButtonText, for: .normal)
        voteButton.titleLabel?.font = .systemFont(
            ofSize: Constants.voteButtonFontSize,
            weight: .medium
        )
        voteButton.titleLabel?.adjustsFontSizeToFitWidth = true
        voteButton.layer.cornerRadius = Constants.voteButtonCornerRadius
        voteButton.layer.borderWidth = Constants.voteButtonBorderWidth
        voteButton.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
        voteButton.addAction(
            UIAction { [weak self] _ in
                self?.onVoteTap?()
            },
            for: .touchUpInside
        )
        voteButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(voteButton)
    }
    
    private func configureLayout() {
        titleToButtonConstraint = titleLabel.trailingAnchor.constraint(
            equalTo: voteButton.leadingAnchor,
            constant: -Constants.titleToButtonSpacing
        )
        titleToContainerConstraint = titleLabel.trailingAnchor.constraint(
            equalTo: containerView.trailingAnchor,
            constant: -Constants.innerInset
        )
        titleToButtonConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.verticalInset
            ),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.verticalInset
            ),
            
            titleLabel.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Constants.innerInset
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.innerInset
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -Constants.innerInset
            ),
            
            voteButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.innerInset
            ),
            voteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            voteButton.widthAnchor.constraint(equalToConstant: Constants.voteButtonWidth),
            voteButton.heightAnchor.constraint(equalToConstant: Constants.voteButtonHeight)
        ])
    }
    
    private func updateVoteButtonVisibility() {
        voteButton.isHidden = !isVoteButtonVisibleValue
        
        if isVoteButtonVisibleValue {
            titleToContainerConstraint?.isActive = false
            titleToButtonConstraint?.isActive = true
        } else {
            titleToButtonConstraint?.isActive = false
            titleToContainerConstraint?.isActive = true
        }
    }
    
    private func updateColors() {
        let alpha = isCompletedValue
            ? Constants.completedAlpha
            : Constants.activeAlpha
        containerView.backgroundColor = base?.withAlphaComponent(alpha)
        titleLabel.textColor = isCompletedValue
            ? labelColor?.withAlphaComponent(Constants.completedTextAlpha)
            : labelColor
        voteButton.setTitleColor(labelColor, for: .normal)
        voteButton.setTitleColor(
            labelColor?.withAlphaComponent(Constants.completedTextAlpha),
            for: .disabled
        )
        voteButton.layer.borderColor = base?.cgColor
        voteButton.backgroundColor = base?.withAlphaComponent(
            Constants.completedAlpha
        )
    }
}
