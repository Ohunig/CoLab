//
//  ChatMessagesController.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import UIKit

final class ChatMessagesController: UIViewController {
    
    private struct Constants {
        static let topBarHorizontalInset: CGFloat = 22
        static let topBarTopInset: CGFloat = -20
        static let topBarHeight: CGFloat = 44
        static let topBarBottomInset: CGFloat = 8
        static let topBarBlurBottomExtension: CGFloat = 18
        static let topBarBlurFadeHeight: CGFloat = 26
        
        static let inputHorizontalInset: CGFloat = 22
        static let inputBottomInset: CGFloat = 14
    }
    
    private let chatTitle: String
    private let interactor: ChatMessagesBusinessLogic
    
    private let backgroundView = MainBackgroundView()
    private let topBarContainerView = UIView()
    private let topBarBackgroundView = UIView()
    private let topBarBlurView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemMaterialDark)
    )
    private let topBarTintView = UIView()
    private let topBarView = ChatMessagesNavigationBarView()
    private let topBarBackgroundMaskLayer = CAGradientLayer()
    
    private let messagesListView: ChatMessagesListView
    private let inputViewContainer = ChatMessageInputView()
    private lazy var dismissKeyboardTapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleScreenTap)
    )
    
    // Во время открытия клавиатуры держим список у latest.
    private var isAdjustingForKeyboard = false
    
    // MARK: Lifecycle
    
    init(
        chatTitle: String,
        interactor: ChatMessagesBusinessLogic,
        collectionDataProvider: ChatMessagesCollectionDataLogic
    ) {
        self.chatTitle = chatTitle
        self.interactor = interactor
        self.messagesListView = ChatMessagesListView(
            collectionDataProvider: collectionDataProvider
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureKeyboardObservers()
        interactor.loadStart()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if messagesListView.hasMessages {
            messagesListView.hideInitialLoading()
        } else {
            messagesListView.showInitialLoadingIfNeeded()
        }
        
        topBarView.showAvatarLoading()
        interactor.listenChatAvatar()
        interactor.loadInitialMessages()
        interactor.startUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messagesListView.syncStateFromProviderIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        interactor.stopUpdates()
        interactor.stopListeningChatAvatar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTopBarBackgroundMask()
        updateMessagesViewportInsets()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        
        configureTopBar()
        configureMessagesArea()
        configureInputView()
        configureDismissKeyboardGesture()
    }
    
    private func configureTopBar() {
        topBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        topBarContainerView.backgroundColor = .clear
        view.addSubview(topBarContainerView)
        
        topBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        topBarBackgroundView.backgroundColor = .clear
        topBarBackgroundView.isUserInteractionEnabled = false
        topBarContainerView.addSubview(topBarBackgroundView)
        
        topBarBlurView.translatesAutoresizingMaskIntoConstraints = false
        topBarBlurView.alpha = 0.58
        topBarBackgroundView.addSubview(topBarBlurView)
        
        topBarTintView.translatesAutoresizingMaskIntoConstraints = false
        topBarTintView.backgroundColor = .clear
        topBarBackgroundView.addSubview(topBarTintView)
        
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        topBarView.title = chatTitle
        topBarView.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        topBarView.onAvatarTap = { [weak self] in
            self?.interactor.loadChatInfoScreen()
        }
        
        topBarContainerView.addSubview(topBarView)
        
        NSLayoutConstraint.activate([
            topBarContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            topBarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            topBarBackgroundView.topAnchor.constraint(equalTo: topBarContainerView.topAnchor),
            topBarBackgroundView.leadingAnchor.constraint(equalTo: topBarContainerView.leadingAnchor),
            topBarBackgroundView.trailingAnchor.constraint(equalTo: topBarContainerView.trailingAnchor),
            topBarBackgroundView.bottomAnchor.constraint(equalTo: topBarContainerView.bottomAnchor),
            
            topBarBlurView.topAnchor.constraint(equalTo: topBarBackgroundView.topAnchor),
            topBarBlurView.leadingAnchor.constraint(equalTo: topBarBackgroundView.leadingAnchor),
            topBarBlurView.trailingAnchor.constraint(equalTo: topBarBackgroundView.trailingAnchor),
            topBarBlurView.bottomAnchor.constraint(equalTo: topBarBackgroundView.bottomAnchor),
            
            topBarTintView.topAnchor.constraint(equalTo: topBarBackgroundView.topAnchor),
            topBarTintView.leadingAnchor.constraint(equalTo: topBarBackgroundView.leadingAnchor),
            topBarTintView.trailingAnchor.constraint(equalTo: topBarBackgroundView.trailingAnchor),
            topBarTintView.bottomAnchor.constraint(equalTo: topBarBackgroundView.bottomAnchor),
            
            topBarView.topAnchor.constraint(
                equalTo: topBarContainerView.safeAreaLayoutGuide.topAnchor,
                constant: Constants.topBarTopInset
            ),
            topBarView.leadingAnchor.constraint(
                equalTo: topBarContainerView.leadingAnchor,
                constant: Constants.topBarHorizontalInset
            ),
            topBarView.trailingAnchor.constraint(
                equalTo: topBarContainerView.trailingAnchor,
                constant: -Constants.topBarHorizontalInset
            ),
            topBarView.heightAnchor.constraint(equalToConstant: Constants.topBarHeight),
            topBarContainerView.bottomAnchor.constraint(
                equalTo: topBarView.bottomAnchor,
                constant: Constants.topBarBlurBottomExtension
            )
        ])
    }

    private func updateTopBarBackgroundMask() {
        let bounds = topBarBackgroundView.bounds
        guard bounds.height > 0 else { return }
        
        let fadeStartY = max(0, bounds.height - Constants.topBarBlurFadeHeight)
        let fadeStartLocation = fadeStartY / bounds.height
        
        topBarBackgroundMaskLayer.frame = bounds
        topBarBackgroundMaskLayer.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        topBarBackgroundMaskLayer.locations = [
            0,
            NSNumber(value: Double(fadeStartLocation)),
            1
        ]
        topBarBackgroundMaskLayer.startPoint = CGPoint(x: 0.5, y: 0)
        topBarBackgroundMaskLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        topBarBackgroundView.layer.mask = topBarBackgroundMaskLayer
    }
    
    private func configureMessagesArea() {
        messagesListView.translatesAutoresizingMaskIntoConstraints = false
        messagesListView.onNeedsPreviousMessages = { [weak self] in
            self?.interactor.loadPreviousMessages()
        }
        
        view.insertSubview(messagesListView, aboveSubview: backgroundView)
        
        NSLayoutConstraint.activate([
            messagesListView.topAnchor.constraint(equalTo: view.topAnchor),
            messagesListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messagesListView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureInputView() {
        inputViewContainer.translatesAutoresizingMaskIntoConstraints = false
        inputViewContainer.onSendTap = { [weak self] text in
            self?.sendMessage(text)
        }
        inputViewContainer.onBeginEditing = { [weak self] in
            self?.beginInputFocusTransition()
        }
        
        view.addSubview(inputViewContainer)
        
        NSLayoutConstraint.activate([
            inputViewContainer.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.inputHorizontalInset
            ),
            inputViewContainer.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.inputHorizontalInset
            ),
            inputViewContainer.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor,
                constant: -Constants.inputBottomInset
            )
        ])
    }
    
    private func configureDismissKeyboardGesture() {
        dismissKeyboardTapGesture.cancelsTouchesInView = false
        dismissKeyboardTapGesture.delegate = self
        view.addGestureRecognizer(dismissKeyboardTapGesture)
    }
    
    // MARK: Keyboard
    
    private func configureKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardDidHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }
    
    private func updateMessagesViewportInsets() {
        let coveredTopHeight = max(
            0,
            topBarView.frame.maxY + Constants.topBarBottomInset
        )
        let coveredBottomHeight = max(
            0,
            view.bounds.maxY - inputViewContainer.frame.minY
        )
        messagesListView.updateViewportInsets(
            coveredTopHeight: coveredTopHeight,
            coveredBottomHeight: coveredBottomHeight
        )
    }
    
    private func animateAlongsideKeyboard(_ notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?
            .doubleValue ?? 0.25
        let rawCurve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?
            .uintValue ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)
        let options = UIView.AnimationOptions(rawValue: rawCurve << 16)
        
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
            self.updateMessagesViewportInsets()
        }
    }
    
    @objc
    private func handleKeyboardWillChangeFrame(_ notification: Notification) {
        guard inputViewContainer.isTextInputActive else { return }
        isAdjustingForKeyboard = true
        messagesListView.beginKeyboardTransition()
        animateAlongsideKeyboard(notification)
    }
    
    @objc
    private func handleKeyboardDidShow(_ notification: Notification) {
        guard inputViewContainer.isTextInputActive else { return }
        view.layoutIfNeeded()
        updateMessagesViewportInsets()
        messagesListView.scrollToLatest(animated: false)
        isAdjustingForKeyboard = false
        messagesListView.endKeyboardTransition()
    }
    
    @objc
    private func handleKeyboardDidHide(_ notification: Notification) {
        isAdjustingForKeyboard = false
        messagesListView.endKeyboardTransition()
    }
    
    // MARK: Input
    
    private func sendMessage(_ text: String) {
        inputViewContainer.clearText()
        messagesListView.forceLatestOnNextAppend()
        interactor.sendMessage(text: text)
        view.endEditing(true)
        messagesListView.scrollToLatest(animated: true)
    }
    
    private func beginInputFocusTransition() {
        isAdjustingForKeyboard = true
        messagesListView.beginKeyboardTransition()
        messagesListView.scrollToLatest(animated: true)
    }
    
    @objc
    private func handleScreenTap() {
        view.endEditing(true)
    }
}

// MARK: - Display logic

extension ChatMessagesController: ChatMessagesDisplayLogic {
    typealias Model = ChatMessagesModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        let bgColor = UIColor(
            hex: viewModel.bg.hex,
            alpha: viewModel.bg.a
        )
        let bgGradientColor = UIColor(
            hex: viewModel.bgGradient.hex,
            alpha: viewModel.bgGradient.a
        )
        let incomingBaseColor = UIColor(
            hex: viewModel.incomingBase.hex,
            alpha: viewModel.incomingBase.a
        )
        let incomingBorderColor = UIColor(
            hex: viewModel.incomingBorder.hex,
            alpha: viewModel.incomingBorder.a
        )
        let incomingTextColor = UIColor(
            hex: viewModel.incomingTextColor.hex,
            alpha: viewModel.incomingTextColor.a
        )
        
        let titleIslandFillColor = incomingBaseColor.withAlphaComponent(0.5)
        let inputSurfaceColor = incomingBaseColor
        
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        topBarTintView.backgroundColor = .black.withAlphaComponent(0.3)
        
        topBarView.controlsBaseColor = incomingBaseColor
        topBarView.titleIslandFillColor = titleIslandFillColor
        topBarView.titleIslandBorderColor = incomingBorderColor
        topBarView.textColor = incomingTextColor
        
        inputViewContainer.baseColor = inputSurfaceColor
        inputViewContainer.borderColor = incomingBorderColor
        inputViewContainer.textColor = incomingTextColor
        inputViewContainer.placeholderColor = incomingTextColor.withAlphaComponent(0.45)
        inputViewContainer.sendGradientStartColor = inputSurfaceColor
        inputViewContainer.sendGradientEndColor = inputSurfaceColor
        inputViewContainer.sendBorderColor = incomingBorderColor
        inputViewContainer.sendIconColor = incomingTextColor
    }
    
    func displayChatAvatar(_ viewModel: Model.ChatAvatar.ViewModel) {
        let image = viewModel.avatarData.flatMap(UIImage.init(data:))
        topBarView.setAvatarImage(image, animated: true)
    }
    
    func displayMessages(_ viewModel: Model.MessagesList.ViewModel) {
        messagesListView.displayMessages(viewModel)
    }
    
    func displayError(_ viewModel: Model.ShowError.ViewModel) {
        messagesListView.hideInitialLoading()
        guard isViewLoaded, view.window != nil else { return }
        guard presentedViewController == nil else { return }
        
        let alert = UIAlertController(
            title: viewModel.errorTitle,
            message: viewModel.errorDescription,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: viewModel.buttonText,
                style: .default
            )
        )
        present(alert, animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ChatMessagesController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        guard gestureRecognizer === dismissKeyboardTapGesture else { return true }
        guard let touchedView = touch.view else { return true }
        
        return !touchedView.isDescendant(of: inputViewContainer)
    }
}
