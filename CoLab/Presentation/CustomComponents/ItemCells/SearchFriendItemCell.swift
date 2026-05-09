//
//  SearchFriendItemCell.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import UIKit

final class SearchFriendItemCell: UITableViewCell {
    private struct Constants {
        static let reuseIdentifier = "SearchFriendItemCell"
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
        
        static let avatarSide: CGFloat = 58
        static let avatarVerticalInset: CGFloat = 5
        
        static let titleFontSize: CGFloat = 18
        static let titleLines = 1
        
        static let placeholderAvatar = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    static let reuseIdentifier = Constants.reuseIdentifier
    
    private let containerView = UIView()
    private let avatarView = CircleImage(UIImage())
    private let avatarOverlay = LoadingOverlay()
    private let titleLabel = UILabel()
    
    private var base: UIColor?
    private var labelColor: UIColor?
    private var titleValue = String()
    private var avatarValue: UIImage?
    private var isAvatarLoadingValue = false
    
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
            updateAvatarState()
        }
    }
    
    var isAvatarLoading: Bool {
        get { isAvatarLoadingValue }
        set {
            isAvatarLoadingValue = newValue
            updateAvatarState()
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
        avatarImage = nil
        isAvatarLoading = false
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
        
        configureContainer()
        configureAvatar()
        configureTitle()
        configureLayout()
        
        baseColor = .white
        textColor = .white
        avatarImage = nil
    }
    
    private func updateAvatarState() {
        if isAvatarLoadingValue {
            avatarView.image = nil
            if avatarOverlay.superview == nil {
                avatarOverlay.isUserInteractionEnabled = false
                avatarOverlay.show(over: avatarView)
            }
        } else {
            avatarOverlay.hide()
            avatarView.image = avatarValue ?? Constants.placeholderAvatar
        }
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
    
    private func configureTitle() {
        titleLabel.font = .systemFont(
            ofSize: Constants.titleFontSize,
            weight: .medium
        )
        titleLabel.numberOfLines = Constants.titleLines
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
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
                constant: Constants.avatarVerticalInset
            ),
            avatarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarView.bottomAnchor.constraint(
                lessThanOrEqualTo: containerView.bottomAnchor,
                constant: -Constants.avatarVerticalInset
            ),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSide),
            avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor),
            
            titleLabel.leadingAnchor.constraint(
                equalTo: avatarView.trailingAnchor,
                constant: Constants.contentSpacing
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.innerInset
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
            )
        ])
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
    }
}
