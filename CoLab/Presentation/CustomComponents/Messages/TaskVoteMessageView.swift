//
//  TaskVoteMessageView.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import UIKit

final class TaskVoteMessageView: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let backgroundAlpha: CGFloat = 0.5
        static let selectedAlpha: CGFloat = 0.42
        static let resolvedAlpha: CGFloat = 0.42
        static let standardAlpha: CGFloat = 1
        static let borderWidth: CGFloat = 1.5
        static let cornerRadius: CGFloat = 24
        
        static let horizontalInset: CGFloat = 18
        static let verticalInset: CGFloat = 16
        static let titleToTextSpacing: CGFloat = 8
        static let textToButtonsSpacing: CGFloat = 14
        static let buttonsSpacing: CGFloat = 10
        static let buttonHeight: CGFloat = 38
        static let buttonCornerRadius: CGFloat = 19
        static let buttonBorderWidth: CGFloat = 1
        
        static let titleFontSize: CGFloat = 13
        static let textFontSize: CGFloat = 17
        static let buttonFontSize: CGFloat = 15
        
        static let titleText = "Голосование по задаче"
        static let approveText = "Выполнена"
        static let rejectText = "Доработать"
        static let approveColor = UIColor.systemGreen
        static let rejectColor = UIColor.systemRed
    }
    
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let approveButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)
    private let buttonsStackView = UIStackView()
    
    private var base: UIColor?
    private var border: UIColor?
    private var textUIColor: UIColor?
    private var currentVoteValue: Bool?
    private var votesForCountValue = 0
    private var votesAgainstCountValue = 0
    private var isResolvedValue = false
    
    var onVote: ((Bool) -> Void)?
    
    var text: String = "" {
        didSet {
            textLabel.text = text
        }
    }
    
    var votesForCount: Int {
        get { votesForCountValue }
        set {
            votesForCountValue = newValue
            updateButtons()
        }
    }
    
    var votesAgainstCount: Int {
        get { votesAgainstCountValue }
        set {
            votesAgainstCountValue = newValue
            updateButtons()
        }
    }
    
    var currentVote: Bool? {
        get { currentVoteValue }
        set {
            currentVoteValue = newValue
            updateButtons()
        }
    }
    
    var isResolved: Bool {
        get { isResolvedValue }
        set {
            isResolvedValue = newValue
            updateButtons()
        }
    }
    
    var baseColor: UIColor? {
        get { base }
        set {
            base = newValue
            backgroundColor = newValue?.withAlphaComponent(Constants.backgroundAlpha)
            updateButtons()
        }
    }
    
    var borderColor: UIColor? {
        get { border }
        set {
            border = newValue
            layer.borderColor = newValue?.cgColor
            updateButtons()
        }
    }
    
    var textColor: UIColor? {
        get { textUIColor }
        set {
            textUIColor = newValue
            titleLabel.textColor = newValue?.withAlphaComponent(0.72)
            textLabel.textColor = newValue
            updateButtons()
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
    
    // MARK: Preferred height
    
    static func preferredHeight(
        for text: String,
        maxWidth: CGFloat
    ) -> CGFloat {
        let labelMaxWidth = max(0, maxWidth - Constants.horizontalInset * 2)
        let textBoundingRect = NSString(string: text).boundingRect(
            with: CGSize(width: labelMaxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [
                .font: UIFont.systemFont(
                    ofSize: Constants.textFontSize,
                    weight: .regular
                )
            ],
            context: nil
        )
        
        let titleHeight = ceil(
            UIFont.systemFont(
                ofSize: Constants.titleFontSize,
                weight: .medium
            ).lineHeight
        )
        
        return Constants.verticalInset
            + titleHeight
            + Constants.titleToTextSpacing
            + ceil(textBoundingRect.height)
            + Constants.textToButtonsSpacing
            + Constants.buttonHeight
            + Constants.verticalInset
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        clipsToBounds = true
        
        configureTitle()
        configureText()
        configureButtons()
        configureLayout()
        updateButtons()
    }
    
    private func configureTitle() {
        titleLabel.text = Constants.titleText
        titleLabel.font = .systemFont(
            ofSize: Constants.titleFontSize,
            weight: .medium
        )
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }
    
    private func configureText() {
        textLabel.font = .systemFont(
            ofSize: Constants.textFontSize,
            weight: .regular
        )
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
    }
    
    private func configureButtons() {
        [approveButton, rejectButton].forEach { button in
            button.titleLabel?.font = .systemFont(
                ofSize: Constants.buttonFontSize,
                weight: .medium
            )
            button.layer.cornerRadius = Constants.buttonCornerRadius
            button.layer.borderWidth = Constants.buttonBorderWidth
            button.addAction(
                UIAction { [weak self, weak button] _ in
                    guard let self, let button else { return }
                    guard !self.isResolvedValue else { return }
                    self.onVote?(button === self.approveButton)
                },
                for: .touchUpInside
            )
        }
        
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = Constants.buttonsSpacing
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.addArrangedSubview(rejectButton)
        buttonsStackView.addArrangedSubview(approveButton)
        addSubview(buttonsStackView)
    }
    
    private func configureLayout() {
        let verticalConstraints = [
            titleLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Constants.verticalInset
            ),
            textLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Constants.titleToTextSpacing
            ),
            buttonsStackView.topAnchor.constraint(
                equalTo: textLabel.bottomAnchor,
                constant: Constants.textToButtonsSpacing
            ),
            buttonsStackView.heightAnchor.constraint(
                equalToConstant: Constants.buttonHeight
            ),
            buttonsStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Constants.verticalInset
            )
        ]
        verticalConstraints.forEach { $0.priority = .defaultHigh }
        
        NSLayoutConstraint.activate(verticalConstraints + [
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.horizontalInset
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.horizontalInset
            ),
            
            textLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    private func updateButtons() {
        alpha = isResolvedValue
            ? Constants.resolvedAlpha
            : Constants.standardAlpha
        isUserInteractionEnabled = !isResolvedValue
        
        configure(
            approveButton,
            title: "\(Constants.approveText) \(votesForCountValue)",
            color: Constants.approveColor,
            isSelected: currentVoteValue == true
        )
        configure(
            rejectButton,
            title: "\(Constants.rejectText) \(votesAgainstCountValue)",
            color: Constants.rejectColor,
            isSelected: currentVoteValue == false
        )
        approveButton.isEnabled = !isResolvedValue
        rejectButton.isEnabled = !isResolvedValue
    }
    
    private func configure(
        _ button: UIButton,
        title: String,
        color: UIColor,
        isSelected: Bool
    ) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.setTitleColor(color.withAlphaComponent(0.6), for: .disabled)
        button.layer.borderColor = color.cgColor
        button.backgroundColor = isSelected
            ? color.withAlphaComponent(Constants.selectedAlpha)
            : .clear
    }
}
