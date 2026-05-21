//
//  CreateTaskController.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import UIKit

final class CreateTaskController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let horizontalInset: CGFloat = 22
        static let topInset: CGFloat = 24
        static let bottomInset: CGFloat = 24
        static let placeholderText = "Введите текст задачи"
        static let addButtonText = "Добавить"
        
        static let textFontSize: CGFloat = 18
        static let textViewMinHeight: CGFloat = 150
        static let buttonMinHeight: CGFloat = 55
        static let spacing: CGFloat = 18
        static let textViewInset: CGFloat = 14
        static let textViewCornerRadius: CGFloat = 22
        static let textViewBorderWidth: CGFloat = 1
        static let surfaceAlpha: CGFloat = 0.5
        static let preferredHeight: CGFloat = 300
    }
    
    private let bgColor: UIColor
    private let bgGradientColor: UIColor
    private let baseColor: UIColor
    private let textUIColor: UIColor
    private let firstGradientColor: UIColor
    private let secondGradientColor: UIColor
    private let onAdd: (String) -> Void
    
    private let backgroundView = MainBackgroundView()
    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let addButton = FilledGradientButton()
    
    // MARK: Lifecycle
    
    init(
        bgColor: UIColor,
        bgGradientColor: UIColor,
        baseColor: UIColor,
        textColor: UIColor,
        firstGradientColor: UIColor,
        secondGradientColor: UIColor,
        onAdd: @escaping (String) -> Void
    ) {
        self.bgColor = bgColor
        self.bgGradientColor = bgGradientColor
        self.baseColor = baseColor
        self.textUIColor = textColor
        self.firstGradientColor = firstGradientColor
        self.secondGradientColor = secondGradientColor
        self.onAdd = onAdd
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: 0, height: Constants.preferredHeight)
        configureUI()
        updateButtonState()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        
        configureTextView()
        configureButton()
        configureKeyboardDismissal()
    }

    private func configureTextView() {
        textView.delegate = self
        textView.textColor = textUIColor
        textView.tintColor = textUIColor
        textView.font = .systemFont(
            ofSize: Constants.textFontSize,
            weight: .regular
        )
        textView.backgroundColor = baseColor.withAlphaComponent(
            Constants.surfaceAlpha
        )
        textView.layer.cornerRadius = Constants.textViewCornerRadius
        textView.layer.borderWidth = Constants.textViewBorderWidth
        textView.layer.borderColor = baseColor.cgColor
        textView.textContainerInset = UIEdgeInsets(
            top: Constants.textViewInset,
            left: Constants.textViewInset,
            bottom: Constants.textViewInset,
            right: Constants.textViewInset
        )
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentCompressionResistancePriority(
            .defaultHigh,
            for: .vertical
        )
        view.addSubview(textView)
        
        placeholderLabel.text = Constants.placeholderText
        placeholderLabel.textColor = textUIColor.withAlphaComponent(0.45)
        placeholderLabel.font = textView.font
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)
        
        let textViewMinHeightConstraint = textView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: Constants.textViewMinHeight
        )
        textViewMinHeightConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.topInset
            ),
            textView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horizontalInset
            ),
            textView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.horizontalInset
            ),
            textViewMinHeightConstraint,
            
            placeholderLabel.topAnchor.constraint(
                equalTo: textView.topAnchor,
                constant: Constants.textViewInset
            ),
            placeholderLabel.leadingAnchor.constraint(
                equalTo: textView.leadingAnchor,
                constant: Constants.textViewInset + 5
            ),
            placeholderLabel.trailingAnchor.constraint(
                equalTo: textView.trailingAnchor,
                constant: -Constants.textViewInset
            )
        ])
    }
    
    private func configureButton() {
        addButton.setTitle(Constants.addButtonText, for: .normal)
        addButton.startColor = firstGradientColor
        addButton.endColor = secondGradientColor
        addButton.addAction(
            UIAction { [weak self] _ in
                self?.addButtonTapped()
            },
            for: .touchUpInside
        )
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setContentCompressionResistancePriority(
            .required,
            for: .vertical
        )
        view.addSubview(addButton)
        
        let topConstraint = addButton.topAnchor.constraint(
            equalTo: textView.bottomAnchor,
            constant: Constants.spacing
        )
        let heightConstraint = addButton.heightAnchor.constraint(
            equalToConstant: Constants.buttonMinHeight
        )
        let bottomConstraint = addButton.bottomAnchor.constraint(
            lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor,
            constant: -Constants.bottomInset
        )
        topConstraint.priority = .defaultHigh
        bottomConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            topConstraint,
            addButton.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            heightConstraint,
            bottomConstraint
        ])
    }
    
    private func configureKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(screenTapped)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateButtonState() {
        addButton.isEnabled = !textView.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    // MARK: Actions
    
    private func addButtonTapped() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        onAdd(text)
        dismiss(animated: true)
    }
    
    @objc
    private func screenTapped() {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate

extension CreateTaskController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateButtonState()
    }
}
