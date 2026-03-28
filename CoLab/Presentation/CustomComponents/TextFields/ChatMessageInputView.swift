//
//  ChatMessageInputView.swift
//  CoLab
//
//  Created by OpenAI on 26.03.2026.
//

import UIKit

final class ChatMessageInputView: UIView {
    
    private struct Constants {
        static let minimumHeight: CGFloat = 52
        static let maximumHeight: CGFloat = 140
        static let gap: CGFloat = 14
        static let fieldHorizontalInset: CGFloat = 18
        static let textTopInset: CGFloat = 12
        static let textBottomInset: CGFloat = 12
        static let sendIconSize: CGFloat = 22
        static let textFontSize: CGFloat = 22
        static let cornerRadius: CGFloat = 26
        static let borderWidth: CGFloat = 1
        static let placeholderFontSize: CGFloat = 22
        static let placeholderText = "Message"
        static let paperplaneImage = "paperplane"
    }
    
    private let fieldContainerView = UIView()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let sendButton = FilledGradientButton()
    
    private var preferredHeight = Constants.minimumHeight
    
    private lazy var textViewHeightConstraint = textView.heightAnchor.constraint(
        equalToConstant: Constants.minimumHeight
    )
    
    var onSendTap: ((String) -> Void)?
    var onBeginEditing: (() -> Void)?
    
    // MARK: Colors
    
    var baseColor: UIColor? {
        didSet {
            fieldContainerView.backgroundColor = baseColor
        }
    }
    
    var borderColor: UIColor? {
        didSet {
            fieldContainerView.layer.borderColor = borderColor?.cgColor
        }
    }
    
    var textColor: UIColor? {
        didSet {
            textView.textColor = textColor
            updatePlaceholder()
        }
    }
    
    var placeholderColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }
    
    var sendGradientStartColor: UIColor = .clear {
        didSet {
            sendButton.startColor = sendGradientStartColor
        }
    }
    
    var sendGradientEndColor: UIColor = .clear {
        didSet {
            sendButton.endColor = sendGradientEndColor
        }
    }
    
    var sendIconColor: UIColor? {
        didSet {
            sendButton.tintColor = sendIconColor
        }
    }
    
    var sendBorderColor: UIColor? {
        didSet {
            sendButton.layer.borderColor = sendBorderColor?.cgColor
        }
    }
    
    // MARK: State
    
    var text: String {
        get { textView.text ?? "" }
        set {
            textView.text = newValue
            updatePlaceholderVisibility()
            updateTextViewHeightIfNeeded()
            updateSendButtonState()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: preferredHeight)
    }
    
    var isTextInputActive: Bool {
        textView.isFirstResponder
    }
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTextViewHeightIfNeeded()
    }
    
    // MARK: Public
    
    func clearText() {
        textView.text = nil
        updatePlaceholderVisibility()
        updateTextViewHeightIfNeeded()
        updateSendButtonState()
    }
    
    func focus() {
        textView.becomeFirstResponder()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        backgroundColor = .clear
        
        configureFieldContainerView()
        configureTextView()
        configureSendButton()
        configureLayout()
        updateTextViewHeightIfNeeded()
        updateSendButtonState()
    }
    
    private func configureFieldContainerView() {
        fieldContainerView.translatesAutoresizingMaskIntoConstraints = false
        fieldContainerView.layer.cornerRadius = Constants.cornerRadius
        fieldContainerView.layer.borderWidth = Constants.borderWidth
        addSubview(fieldContainerView)
    }
    
    private func configureTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(
            ofSize: Constants.textFontSize,
            weight: .regular
        )
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.keyboardDismissMode = .interactive
        textView.returnKeyType = .send
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(
            top: Constants.textTopInset,
            left: 0,
            bottom: Constants.textBottomInset,
            right: 0
        )
        updatePlaceholder()
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.font = .systemFont(
            ofSize: Constants.placeholderFontSize,
            weight: .regular
        )
        
        fieldContainerView.addSubview(textView)
        textView.addSubview(placeholderLabel)
    }
    
    private func configureSendButton() {
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.borderWidth = Constants.borderWidth
        sendButton.setImage(
            UIImage(systemName: Constants.paperplaneImage),
            for: .normal
        )
        sendButton.imageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: Constants.sendIconSize,
            weight: .medium
        )
        sendButton.addAction(
            UIAction { [weak self] _ in
                self?.sendCurrentText()
            },
            for: .touchUpInside
        )
        addSubview(sendButton)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: Constants.minimumHeight),
            sendButton.heightAnchor.constraint(equalToConstant: Constants.minimumHeight),
            
            fieldContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            fieldContainerView.topAnchor.constraint(equalTo: topAnchor),
            fieldContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            fieldContainerView.trailingAnchor.constraint(
                equalTo: sendButton.leadingAnchor,
                constant: -Constants.gap
            ),
            fieldContainerView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Constants.minimumHeight
            ),
            
            textView.leadingAnchor.constraint(
                equalTo: fieldContainerView.leadingAnchor,
                constant: Constants.fieldHorizontalInset
            ),
            textView.trailingAnchor.constraint(
                equalTo: fieldContainerView.trailingAnchor,
                constant: -Constants.fieldHorizontalInset
            ),
            textView.topAnchor.constraint(equalTo: fieldContainerView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: fieldContainerView.bottomAnchor),
            textViewHeightConstraint,
            
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: textView.trailingAnchor
            ),
            placeholderLabel.topAnchor.constraint(
                equalTo: textView.topAnchor,
                constant: Constants.textTopInset
            )
        ])
    }
    
    // MARK: Update state
    
    private func updatePlaceholder() {
        let color = placeholderColor ?? textColor?.withAlphaComponent(0.55) ?? .lightGray
        placeholderLabel.text = Constants.placeholderText
        placeholderLabel.textColor = color
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
    }
    
    private func updateSendButtonState() {
        let trimmedText = textView.text?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ) ?? ""
        sendButton.isEnabled = !trimmedText.isEmpty
    }
    
    // Высоту поля считаем от реальной высоты текста.
    // Пока текста мало, держим стандартную высоту.
    // Когда текста становится больше, поле растёт вверх до верхнего лимита.
    private func updateTextViewHeightIfNeeded() {
        let availableWidth = max(
            textView.bounds.width,
            fieldContainerView.bounds.width - Constants.fieldHorizontalInset * 2
        )
        guard availableWidth > 0 else { return }
        
        let measuredHeight = textView.sizeThatFits(
            CGSize(
                width: availableWidth,
                height: CGFloat.greatestFiniteMagnitude
            )
        ).height
        let clampedHeight = min(
            Constants.maximumHeight,
            max(Constants.minimumHeight, ceil(measuredHeight))
        )
        
        guard abs(clampedHeight - preferredHeight) > 0.5 else {
            textView.isScrollEnabled = measuredHeight > Constants.maximumHeight
            return
        }
        
        preferredHeight = clampedHeight
        textViewHeightConstraint.constant = clampedHeight
        textView.isScrollEnabled = measuredHeight > Constants.maximumHeight
        invalidateIntrinsicContentSize()
    }
    
    private func sendCurrentText() {
        let trimmedText = textView.text?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ) ?? ""
        guard !trimmedText.isEmpty else { return }
        onSendTap?(trimmedText)
    }
}

// MARK: - UITextViewDelegate

extension ChatMessageInputView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        onBeginEditing?()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        updateTextViewHeightIfNeeded()
        updateSendButtonState()
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText replacement: String
    ) -> Bool {
        guard replacement == "\n" else { return true }
        sendCurrentText()
        return false
    }
}
