//
//  SearchChatItemCell.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import UIKit

final class SearchChatItemCell: UITableViewCell {
    private struct Constants {
        static let reuseIdentifier = "SearchChatItemCell"
        static let fatalError = "init(coder:) has not been implemented"
        
        static let animateDuration: CGFloat = 0.06
        static let standardAlpha: CGFloat = 1
        static let tappedAlpha: CGFloat = 0.5
        
        static let verticalInset: CGFloat = 6
        static let innerInset: CGFloat = 14
        static let contentSpacing: CGFloat = 12
        static let buttonSpacing: CGFloat = 18
        
        static let containerCornerRadius: CGFloat = 25
        static let containerBorderWidth: CGFloat = 1
        static let containerAlpha: CGFloat = 0.5
        static let secondaryTextAlpha: CGFloat = 0.72
        static let avatarBackgroundAlpha: CGFloat = 0.12
        
        static let avatarSide: CGFloat = 58
        static let buttonSide: CGFloat = 52
        static let plusFontSize: CGFloat = 18
        
        static let titleFontSize: CGFloat = 18
        static let titleLines = 1
        static let descriptionFontSize: CGFloat = 14
        static let descriptionLines = 1
        static let textStackSpacing: CGFloat = 4
        
        static let placeholderAvatar = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    static let reuseIdentifier = Constants.reuseIdentifier
    
    private let containerView = UIView()
    private let avatarView = CircleImage(Constants.placeholderAvatar)
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let textStackView = UIStackView()
    private let actionButton = FilledGradientButton()
    
    private var base: UIColor?
    private var labelColor: UIColor?
    private var titleValue = String()
    private var descriptionValue = String()
    private var avatarValue: UIImage?
    
    // MARK: Computed properties
    
    var baseColor: UIColor? {
        get { base }
        set {
            base = newValue
            containerView.backgroundColor = newValue?.withAlphaComponent(
                Constants.containerAlpha
            )
            containerView.layer.borderColor = newValue?.cgColor
        }
    }
    
    var textColor: UIColor? {
        get { labelColor }
        set {
            labelColor = newValue
            titleLabel.textColor = newValue
            descriptionLabel.textColor = newValue?.withAlphaComponent(
                Constants.secondaryTextAlpha
            )
        }
    }
    
    var gradientStartColor: UIColor = .clear {
        didSet {
            actionButton.startColor = gradientStartColor
        }
    }
    
    var gradientEndColor: UIColor = .clear {
        didSet {
            actionButton.endColor = gradientEndColor
        }
    }
    
    var title: String {
        get { titleValue }
        set {
            titleValue = newValue
            titleLabel.text = newValue
        }
    }

    var chatDescription: String {
        get { descriptionValue }
        set {
            descriptionValue = newValue
            descriptionLabel.text = newValue
            descriptionLabel.isHidden = newValue.isEmpty
        }
    }
    
    var avatarImage: UIImage? {
        get { avatarValue }
        set {
            avatarValue = newValue
            avatarView.image = newValue ?? Constants.placeholderAvatar
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
    
    // MARK: Prepare for reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title = ""
        chatDescription = ""
        avatarImage = nil
        updatePressedState(isPressed: false, animated: false)
    }
    
    // MARK: Actions processing
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updatePressedState(isPressed: highlighted, animated: animated)
    }
    
    private func updatePressedState(isPressed: Bool, animated: Bool) {
        let changes = {
            self.containerView.alpha = isPressed
                ? Constants.tappedAlpha
                : Constants.standardAlpha
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
        
        configureContainer()
        configureAvatar()
        configureText()
        configureActionButton()
        configureLayout()
        
        baseColor = .white
        textColor = .white
        avatarImage = nil
    }
    
    private func configureContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = Constants.containerCornerRadius
        containerView.layer.borderWidth = Constants.containerBorderWidth
        containerView.clipsToBounds = true
        contentView.addSubview(containerView)
    }
    
    private func configureAvatar() {
        avatarView.borderColor = .clear
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(avatarView)
    }
    
    private func configureText() {
        titleLabel.font = .systemFont(
            ofSize: Constants.titleFontSize,
            weight: .medium
        )
        titleLabel.numberOfLines = Constants.titleLines
        titleLabel.lineBreakMode = .byTruncatingTail

        descriptionLabel.font = .systemFont(
            ofSize: Constants.descriptionFontSize,
            weight: .regular
        )
        descriptionLabel.numberOfLines = Constants.descriptionLines
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.isHidden = true

        textStackView.axis = .vertical
        textStackView.spacing = Constants.textStackSpacing
        textStackView.alignment = .fill
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        containerView.addSubview(textStackView)
    }
    
    private func configureActionButton() {
        let plusImage = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: Constants.plusFontSize,
                weight: .regular
            )
        )
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.startColor = .clear
        actionButton.endColor = .clear
        actionButton.tintColor = .black
        actionButton.setImage(plusImage, for: .normal)
        actionButton.layer.cornerRadius = Constants.buttonSide / 2
        actionButton.isUserInteractionEnabled = false
        containerView.addSubview(actionButton)
    }
    
    private func configureLayout() {
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
            
            avatarView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.innerInset
            ),
            avatarView.topAnchor.constraint(
                greaterThanOrEqualTo: containerView.topAnchor,
                constant: Constants.verticalInset
            ),
            avatarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarView.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.bottomAnchor,
                constant: -Constants.verticalInset
            ),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSide),
            avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor),
            
            actionButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.innerInset
            ),
            actionButton.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            actionButton.widthAnchor.constraint(
                equalToConstant: Constants.buttonSide
            ),
            actionButton.heightAnchor.constraint(equalTo: actionButton.widthAnchor),
            
            textStackView.leadingAnchor.constraint(
                equalTo: avatarView.trailingAnchor,
                constant: Constants.contentSpacing
            ),
            textStackView.trailingAnchor.constraint(
                equalTo: actionButton.leadingAnchor,
                constant: -Constants.buttonSpacing
            ),
            textStackView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            textStackView.topAnchor.constraint(
                greaterThanOrEqualTo: containerView.topAnchor,
                constant: Constants.innerInset
            ),
            textStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.bottomAnchor,
                constant: -Constants.innerInset
            )
        ])
    }
}
