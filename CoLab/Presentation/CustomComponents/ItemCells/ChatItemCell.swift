//
//  ChatItemCell.swift
//  CoLab
//
//  Created by User on 19.03.2026.
//

import UIKit

final class ChatItemCell: UITableViewCell {
    private struct Constants {
        static let reuseIdentifier = "ChatItemCell"
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
        static let secondaryTextAlpha: CGFloat = 0.72
        static let avatarPlaceholderAlpha: CGFloat = 0.8
        static let avatarBackgroundAlpha: CGFloat = 0.12
        
        static let avatarSide: CGFloat = 56
        static let avatarCornerRadius: CGFloat = 28
        
        static let titleFontSize: CGFloat = 18
        static let subtitleFontSize: CGFloat = 14
        static let metaFontSize: CGFloat = 12
        static let subtitleLines = 1
        static let textStackSpacing: CGFloat = 4
        static let titleRowSpacing: CGFloat = 8
    }
    
    static let reuseIdentifier = Constants.reuseIdentifier
    
    private let containerView = UIView()
    private let avatarImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let timeLabel = UILabel()
    private let textStackView = UIStackView()
    private let titleRowStackView = UIStackView()
    
    private var base: UIColor?
    private var labelColor: UIColor?
    private var titleValue = String()
    private var subtitleValue = String()
    private var timeValue = String()
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
            subtitleLabel.textColor = newValue?.withAlphaComponent(
                Constants.secondaryTextAlpha
            )
            timeLabel.textColor = newValue?.withAlphaComponent(
                Constants.secondaryTextAlpha
            )
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
    
    var subtitle: String {
        get { subtitleValue }
        set {
            subtitleValue = newValue
            subtitleLabel.text = newValue
        }
    }
    
    var time: String {
        get { timeValue }
        set {
            timeValue = newValue
            timeLabel.text = newValue
        }
    }
    
    var avatarImage: UIImage? {
        get { avatarValue }
        set {
            avatarValue = newValue
            avatarImageView.image = newValue ?? UIImage(systemName: "person.crop.circle.fill")
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
        subtitle = ""
        time = ""
        avatarImage = nil
        updatePressedState(isPressed: false, animated: false)
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        updatePressedState(isPressed: false, animated: false)
        
        configureContainer()
        configureAvatar()
        configureLabels()
        configureLayout()
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
    
    private func configureLabels() {
        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .medium)
        
        subtitleLabel.font = .systemFont(ofSize: Constants.subtitleFontSize, weight: .regular)
        subtitleLabel.numberOfLines = Constants.subtitleLines
        
        timeLabel.font = .systemFont(ofSize: Constants.metaFontSize, weight: .medium)
        timeLabel.textAlignment = .right
        timeLabel.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
        
        titleRowStackView.axis = .horizontal
        titleRowStackView.spacing = Constants.titleRowSpacing
        titleRowStackView.alignment = .center
        titleRowStackView.translatesAutoresizingMaskIntoConstraints = false
        titleRowStackView.addArrangedSubview(titleLabel)
        titleRowStackView.addArrangedSubview(timeLabel)
        
        textStackView.axis = .vertical
        textStackView.spacing = Constants.textStackSpacing
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.addArrangedSubview(titleRowStackView)
        textStackView.addArrangedSubview(subtitleLabel)
        containerView.addSubview(textStackView)
        
        baseColor = .white
        textColor = .white
        avatarImage = nil
    }
    
    private func configureLayout() {
        configureContainerConstraints()
        configureAvatarConstraints()
        configureTextConstraints()
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
            avatarImageView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            avatarImageView.widthAnchor.constraint(
                equalToConstant: Constants.avatarSide
            ),
            avatarImageView.heightAnchor.constraint(
                equalTo: avatarImageView.widthAnchor
            )
        ])
    }
    
    private func configureTextConstraints() {
        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: Constants.contentSpacing
            ),
            textStackView.topAnchor.constraint(
                greaterThanOrEqualTo: containerView.topAnchor,
                constant: Constants.innerInset
            ),
            textStackView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            textStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.bottomAnchor,
                constant: -Constants.innerInset
            ),
            textStackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.innerInset
            )
        ])
    }
}
