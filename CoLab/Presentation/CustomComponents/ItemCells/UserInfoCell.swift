//
//  UserInfoCell.swift
//  CoLab
//
//  Created by User on 19.04.2026.
//

import UIKit

final class UserInfoCell: UITableViewCell {
    private struct Constants {
        static let reuseIdentifier = "UserInfoCell"
        static let fatalError = "init(coder:) has not been implemented"
        static let animateDuration: CGFloat = 0.06
        static let standardAlpha: CGFloat = 1
        static let tappedAlpha: CGFloat = 0.5
        
        static let verticalInset: CGFloat = 6
        static let innerInset: CGFloat = 14
        static let contentSpacing: CGFloat = 12
        
        static let containerCornerRadius: CGFloat = 25
        static let containerBorderWidth: CGFloat = 1
        static let containerAlpha: CGFloat = 0.5
        static let avatarPlaceholderAlpha: CGFloat = 0.8
        static let avatarBackgroundAlpha: CGFloat = 0.12
        
        static let avatarSide: CGFloat = 56
        static let avatarCornerRadius: CGFloat = 28
        static let chevronSide: CGFloat = 20
        
        static let titleFontSize: CGFloat = 18
        static let placeholderAvatar = "person.crop.circle.fill"
        static let chevronImage = "chevron.right"
    }
    
    static let reuseIdentifier = Constants.reuseIdentifier
    
    private let containerView = UIView()
    private let avatarImageView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView(
        image: UIImage(systemName: Constants.chevronImage)?
            .withRenderingMode(.alwaysTemplate)
    )
    
    private var base: UIColor?
    private var labelColor: UIColor?
    private var titleValue = String()
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
            avatarImageView.backgroundColor = newValue?.withAlphaComponent(
                Constants.avatarBackgroundAlpha
            )
        }
    }
    
    var textColor: UIColor? {
        get { labelColor }
        set {
            labelColor = newValue
            titleLabel.textColor = newValue
            avatarImageView.tintColor = newValue?.withAlphaComponent(
                Constants.avatarPlaceholderAlpha
            )
        }
    }
    
    var title: String {
        get { titleValue }
        set {
            titleValue = newValue
            titleLabel.text = newValue
        }
    }
    
    var avatarImage: UIImage? {
        get { avatarValue }
        set {
            avatarValue = newValue
            avatarImageView.image = newValue
                ?? UIImage(systemName: Constants.placeholderAvatar)
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
        avatarImage = nil
        updatePressedState(isPressed: false, animated: false)
    }
    
    // MARK: Highlight
    
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
        updatePressedState(isPressed: false, animated: false)
        
        configureContainer()
        configureAvatar()
        configureTitle()
        configureChevron()
        configureLayout()
    }
    
    private func configureContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = Constants.containerCornerRadius
        containerView.layer.borderWidth = Constants.containerBorderWidth
        contentView.addSubview(containerView)
    }
    
    private func configureAvatar() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Constants.avatarCornerRadius
        containerView.addSubview(avatarImageView)
    }
    
    private func configureTitle() {
        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .medium)
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        baseColor = .white
        textColor = .white
        avatarImage = nil
    }
    
    private func configureChevron() {
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.contentMode = .scaleAspectFit
        containerView.addSubview(chevronImageView)
    }
    
    private func configureLayout() {
        configureContainerConstraints()
        configureAvatarConstraints()
        configureChevronConstraints()
        configureTitleConstraints()
    }
    
    private func configureContainerConstraints() {
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
            )
        ])
    }
    
    private func configureAvatarConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.innerInset
            ),
            avatarImageView.topAnchor.constraint(
                greaterThanOrEqualTo: containerView.topAnchor,
                constant: Constants.innerInset
            ),
            avatarImageView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            avatarImageView.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.bottomAnchor,
                constant: -Constants.innerInset
            ),
            avatarImageView.widthAnchor.constraint(
                equalToConstant: Constants.avatarSide
            ),
            avatarImageView.heightAnchor.constraint(
                equalTo: avatarImageView.widthAnchor
            )
        ])
    }
    
    private func configureChevronConstraints() {
        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.innerInset
            ),
            chevronImageView.topAnchor.constraint(
                greaterThanOrEqualTo: containerView.topAnchor,
                constant: Constants.innerInset
            ),
            chevronImageView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            chevronImageView.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.bottomAnchor,
                constant: -Constants.innerInset
            ),
            chevronImageView.widthAnchor.constraint(
                equalToConstant: Constants.chevronSide
            ),
            chevronImageView.heightAnchor.constraint(
                equalTo: chevronImageView.widthAnchor
            )
        ])
    }
    
    private func configureTitleConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: Constants.contentSpacing
            ),
            titleLabel.topAnchor.constraint(
                greaterThanOrEqualTo: containerView.topAnchor,
                constant: Constants.innerInset
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            titleLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.bottomAnchor,
                constant: -Constants.innerInset
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: chevronImageView.leadingAnchor,
                constant: -Constants.contentSpacing
            )
        ])
    }
    
    // MARK: Tint color did change
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        chevronImageView.tintColor = tintColor
    }
}
