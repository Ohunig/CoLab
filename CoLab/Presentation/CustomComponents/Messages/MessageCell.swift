//
//  MessageCell.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import UIKit

final class MessageCell: UICollectionViewCell {
    
    enum Direction: Equatable {
        case incoming
        case outgoing
        case description
        case taskVote
    }
    
    private struct Constants {
        static let reuseIdentifier = "MessageCell"
        static let verticalInset: CGFloat = 8
        static let avatarSide: CGFloat = 40
        static let avatarToBubbleGap: CGFloat = 10
        static let maxBubbleWidthMultiplier: CGFloat = 0.7
        static let maxDescriptionWidthMultiplier: CGFloat = 0.78
        static let maxTaskVoteWidthMultiplier: CGFloat = 0.86
        static let contentUpdateAnimationDuration: TimeInterval = 0.22
        static let invertedTransform = CGAffineTransform(scaleX: 1, y: -1)
        
        static let placeholderAvatar = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    static let reuseIdentifier = Constants.reuseIdentifier
    
    private let bubbleView = MessageBubbleView()
    private let eventDescriptionView = ChatDescriptionView()
    private let taskVoteView = TaskVoteMessageView()
    private let avatarView = CircleImage(UIImage())
    private let avatarOverlay = LoadingOverlay()
    private var renderedMessageId: String?
    private var renderedAvatarData: Data?
    private var renderedIsAvatarLoading: Bool?
    private var activeDirectionConstraints: [NSLayoutConstraint] = []
    
    private lazy var avatarLeadingConstraint = avatarView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor
    )
    private lazy var avatarBottomConstraint = avatarView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor,
        constant: -Constants.verticalInset
    )
    
    private lazy var incomingBubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(
        equalTo: avatarView.trailingAnchor,
        constant: Constants.avatarToBubbleGap
    )
    private lazy var outgoingBubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor
    )
    private lazy var bubbleTopConstraint = bubbleView.topAnchor.constraint(
        equalTo: contentView.topAnchor,
        constant: Constants.verticalInset
    )
    private lazy var bubbleBottomConstraint = bubbleView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor,
        constant: -Constants.verticalInset
    )
    
    private lazy var maxWidthConstraint = bubbleView.widthAnchor.constraint(
        lessThanOrEqualTo: contentView.widthAnchor,
        multiplier: Constants.maxBubbleWidthMultiplier
    )
    private lazy var descriptionTopConstraint = eventDescriptionView.topAnchor.constraint(
        equalTo: contentView.topAnchor,
        constant: Constants.verticalInset
    )
    private lazy var descriptionBottomConstraint = eventDescriptionView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor,
        constant: -Constants.verticalInset
    )
    private lazy var descriptionCenterXConstraint = eventDescriptionView.centerXAnchor.constraint(
        equalTo: contentView.centerXAnchor
    )
    private lazy var descriptionLeadingConstraint = eventDescriptionView.leadingAnchor.constraint(
        greaterThanOrEqualTo: contentView.leadingAnchor
    )
    private lazy var descriptionTrailingConstraint = eventDescriptionView.trailingAnchor.constraint(
        lessThanOrEqualTo: contentView.trailingAnchor
    )
    private lazy var descriptionWidthConstraint = eventDescriptionView.widthAnchor.constraint(
        equalTo: contentView.widthAnchor,
        multiplier: Constants.maxDescriptionWidthMultiplier
    )
    private lazy var taskVoteTopConstraint = taskVoteView.topAnchor.constraint(
        equalTo: contentView.topAnchor,
        constant: Constants.verticalInset
    )
    private lazy var taskVoteBottomConstraint = taskVoteView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor,
        constant: -Constants.verticalInset
    )
    private lazy var taskVoteCenterXConstraint = taskVoteView.centerXAnchor.constraint(
        equalTo: contentView.centerXAnchor
    )
    private lazy var taskVoteWidthConstraint = taskVoteView.widthAnchor.constraint(
        equalTo: contentView.widthAnchor,
        multiplier: Constants.maxTaskVoteWidthMultiplier
    )
    
    var onTaskVote: ((Bool) -> Void)? {
        get { taskVoteView.onVote }
        set { taskVoteView.onVote = newValue }
    }
    
    var direction: Direction = .incoming {
        didSet {
            switch direction {
            case .incoming:
                bubbleView.direction = .incoming
                bubbleView.reservesSenderNameSpace = true
            case .outgoing:
                bubbleView.direction = .outgoing
                bubbleView.reservesSenderNameSpace = false
            case .description:
                bubbleView.reservesSenderNameSpace = false
            case .taskVote:
                bubbleView.reservesSenderNameSpace = false
            }
            updateDirection()
        }
    }
    
    var text: String {
        get { bubbleView.text }
        set {
            bubbleView.text = newValue
            eventDescriptionView.text = newValue
            taskVoteView.text = newValue
        }
    }
    
    var senderName: String? {
        get { bubbleView.senderName }
        set { bubbleView.senderName = newValue }
    }
    
    var bubbleColor: UIColor? {
        get { bubbleView.fillColor }
        set {
            bubbleView.fillColor = newValue
            eventDescriptionView.baseColor = newValue
            taskVoteView.baseColor = newValue
        }
    }
    
    var bubbleBorderColor: UIColor? {
        get { bubbleView.borderColor }
        set {
            bubbleView.borderColor = newValue
            taskVoteView.borderColor = newValue
        }
    }
    
    var bubbleGradientStartColor: UIColor? {
        get { bubbleView.gradientStartColor }
        set { bubbleView.gradientStartColor = newValue }
    }
    
    var bubbleGradientEndColor: UIColor? {
        get { bubbleView.gradientEndColor }
        set { bubbleView.gradientEndColor = newValue }
    }
    
    var messageTextColor: UIColor? {
        get { bubbleView.textColor }
        set {
            bubbleView.textColor = newValue
            eventDescriptionView.textColor = newValue
            taskVoteView.textColor = newValue
        }
    }
    
    var senderTextColor: UIColor? {
        get { bubbleView.senderTextColor }
        set { bubbleView.senderTextColor = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareLayoutForReuse()
        renderedMessageId = nil
        renderedAvatarData = nil
        renderedIsAvatarLoading = nil
        text = ""
        senderName = nil
        avatarView.image = nil
        avatarOverlay.hide()
        bubbleBorderColor = nil
        bubbleGradientStartColor = nil
        bubbleGradientEndColor = nil
        senderTextColor = nil
        taskVoteView.isResolved = false
        onTaskVote = nil
    }

    func beginRendering(messageId: String) -> Bool {
        let shouldAnimate = renderedMessageId == messageId && window != nil
        renderedMessageId = messageId
        return shouldAnimate
    }

    func setSenderName(_ senderName: String?, animated: Bool) {
        guard bubbleView.senderName != senderName else { return }
        
        guard animated else {
            bubbleView.senderName = senderName
            return
        }
        
        UIView.transition(
            with: bubbleView,
            duration: Constants.contentUpdateAnimationDuration,
            options: [.transitionCrossDissolve, .allowAnimatedContent, .curveEaseInOut]
        ) {
            self.bubbleView.senderName = senderName
        }
    }

    func setAvatarData(
        _ avatarData: Data?,
        isLoading: Bool
    ) {
        guard renderedAvatarData != avatarData
                || renderedIsAvatarLoading != isLoading else {
            return
        }
        renderedAvatarData = avatarData
        renderedIsAvatarLoading = isLoading
        
        if isLoading {
            avatarView.image = nil
            if avatarOverlay.superview == nil {
                avatarOverlay.isUserInteractionEnabled = false
                avatarOverlay.show(over: avatarView)
            }
        } else {
            avatarOverlay.hide()
            avatarView.image = avatarData.flatMap(UIImage.init(data:))
                ?? Constants.placeholderAvatar
        }
    }
    
    func setTaskVote(
        votesForCount: Int,
        votesAgainstCount: Int,
        currentVote: Bool?,
        isResolved: Bool
    ) {
        taskVoteView.votesForCount = votesForCount
        taskVoteView.votesAgainstCount = votesAgainstCount
        taskVoteView.currentVote = currentVote
        taskVoteView.isResolved = isResolved
    }
    
    static func preferredHeight(
        for text: String,
        senderName: String?,
        direction: Direction,
        width: CGFloat
    ) -> CGFloat {
        let bubbleWidth = width * Constants.maxBubbleWidthMultiplier
        let bubbleHeight = MessageBubbleView.preferredHeight(
            for: text,
            senderName: direction == .incoming ? senderName : nil,
            maxWidth: bubbleWidth,
            reservesSenderNameSpace: direction == .incoming
        )
        
        switch direction {
        case .outgoing:
            return bubbleHeight + Constants.verticalInset * 2
        case .incoming:
            return max(Constants.avatarSide, bubbleHeight)
                + Constants.verticalInset * 2
        case .description:
            let descriptionWidth = width * Constants.maxDescriptionWidthMultiplier
            return ChatDescriptionView.preferredHeight(
                for: text,
                maxWidth: descriptionWidth,
                numberOfLines: 1
            ) + Constants.verticalInset * 2
        case .taskVote:
            let taskVoteWidth = width * Constants.maxTaskVoteWidthMultiplier
            return TaskVoteMessageView.preferredHeight(
                for: text,
                maxWidth: taskVoteWidth
            ) + Constants.verticalInset * 2
        }
    }
    
    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.transform = Constants.invertedTransform
        
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.borderColor = .clear
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.direction = .incoming
        bubbleView.reservesSenderNameSpace = true
        
        eventDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        eventDescriptionView.isHidden = true
        eventDescriptionView.numberOfLines = 1
        eventDescriptionView.lineBreakMode = .byTruncatingTail
        
        taskVoteView.translatesAutoresizingMaskIntoConstraints = false
        taskVoteView.isHidden = true
        
        contentView.addSubview(avatarView)
        contentView.addSubview(bubbleView)
        contentView.addSubview(eventDescriptionView)
        contentView.addSubview(taskVoteView)
        
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSide),
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSide),
            avatarBottomConstraint
        ])
        
        updateDirection()
    }
    
    private func updateDirection() {
        NSLayoutConstraint.deactivate(activeDirectionConstraints)
        
        switch direction {
        case .incoming:
            avatarView.isHidden = false
            bubbleView.isHidden = false
            eventDescriptionView.isHidden = true
            taskVoteView.isHidden = true
            activeDirectionConstraints = [
                bubbleTopConstraint,
                bubbleBottomConstraint,
                maxWidthConstraint,
                avatarLeadingConstraint,
                incomingBubbleLeadingConstraint
            ]
        case .outgoing:
            avatarView.isHidden = true
            bubbleView.isHidden = false
            eventDescriptionView.isHidden = true
            taskVoteView.isHidden = true
            activeDirectionConstraints = [
                bubbleTopConstraint,
                bubbleBottomConstraint,
                maxWidthConstraint,
                outgoingBubbleTrailingConstraint
            ]
        case .description:
            avatarView.isHidden = true
            bubbleView.isHidden = true
            eventDescriptionView.isHidden = false
            taskVoteView.isHidden = true
            activeDirectionConstraints = [
                descriptionTopConstraint,
                descriptionBottomConstraint,
                descriptionCenterXConstraint,
                descriptionLeadingConstraint,
                descriptionTrailingConstraint,
                descriptionWidthConstraint
            ]
        case .taskVote:
            avatarView.isHidden = true
            bubbleView.isHidden = true
            eventDescriptionView.isHidden = true
            taskVoteView.isHidden = false
            activeDirectionConstraints = [
                taskVoteTopConstraint,
                taskVoteBottomConstraint,
                taskVoteCenterXConstraint,
                taskVoteWidthConstraint
            ]
        }
        
        NSLayoutConstraint.activate(activeDirectionConstraints)
    }
    
    private func prepareLayoutForReuse() {
        NSLayoutConstraint.deactivate(activeDirectionConstraints)
        activeDirectionConstraints = []
        
        avatarView.isHidden = true
        bubbleView.isHidden = true
        eventDescriptionView.isHidden = true
        taskVoteView.isHidden = true
        
        bubbleView.reservesSenderNameSpace = false
    }
}
