//
//  ChatInfoController.swift
//  CoLab
//
//  Created by User on 14.04.2026.
//

import Foundation
import UIKit

final class ChatInfoController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let horisontalInset: CGFloat = 22
        static let backToUnsafe: CGFloat = 30
        
        static let avatarSize: CGFloat = 170
        static let avatarTop: CGFloat = 40
        static let avatarGap: CGFloat = 10
        static let avatarLabelFontSize: CGFloat = 40
        static let avatarLabelLines = 2
        static let updateDuration = 0.25
        
        static let unknownTitle = "..."
        
        static let cellsHeight: CGFloat = 80
        static let stackTop: CGFloat = 55
        static let stackGap: CGFloat = 20
        static let stackBottomInset: CGFloat = 24
        
        static let memberIcon = "person"
        
        static let placeholderAvatar = UIImage(systemName: "person")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    private let interactor: ChatInfoBusinessLogic
    
    private let backgroundView = MainBackgroundView()
    private let backButton = BackNavBarButton()
    
    private let avatarOverlay = LoadingOverlay()
    private let avatar = CircleImage(Constants.placeholderAvatar)
    private let chatTitle = UILabel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let membersStack = UIStackView()
    
    private var membersBaseColor: UIColor?
    private var membersTintColor: UIColor?
    private var membersTextColor: UIColor?
    private var currentMemberNames: [String] = []
    
    private lazy var avatarTopConstraint = avatar.topAnchor.constraint(
        equalTo: contentView.topAnchor,
        constant: Constants.avatarTop
    )
    
    // MARK: Lifecycle
    
    init(interactor: ChatInfoBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        interactor.loadStart()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarTopConstraint.constant = view.safeAreaInsets.top + Constants.avatarTop
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        
        configureScrollView()
        configureBackButton()
        configureAvatarWithTitle()
        configureMembers()
    }
    
    private func configureBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addAction(
            UIAction { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            },
            for: .touchUpInside
        )
        view.addSubview(backButton)
        NSLayoutConstraint.activate(
            [
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset),
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -Constants.backToUnsafe)
            ]
        )
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate(
            [
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
            ]
        )
    }
    
    private func configureAvatarWithTitle() {
        avatarOverlay.show(over: avatar)
        
        chatTitle.numberOfLines = Constants.avatarLabelLines
        chatTitle.font = .systemFont(ofSize: Constants.avatarLabelFontSize, weight: .medium)
        chatTitle.text = Constants.unknownTitle
        chatTitle.textAlignment = .center
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        chatTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatar)
        contentView.addSubview(chatTitle)
        
        NSLayoutConstraint.activate(
            [
                avatar.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
                avatar.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
                avatarTopConstraint,
                avatar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                
                chatTitle.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: Constants.avatarGap),
                chatTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horisontalInset),
                chatTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horisontalInset)
            ]
        )
    }
    
    private func configureMembers() {
        membersStack.axis = .vertical
        membersStack.spacing = Constants.stackGap
        membersStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(membersStack)
        
        NSLayoutConstraint.activate(
            [
                membersStack.topAnchor.constraint(equalTo: chatTitle.bottomAnchor, constant: Constants.stackTop),
                membersStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horisontalInset),
                membersStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horisontalInset),
                membersStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.stackBottomInset)
            ]
        )
    }
    
    private func updateMemberCells(with memberNames: [String]) {
        // Пересобираем список участников полностью, так как экран показывает
        // короткий стек и здесь важнее простота поддержки, чем частичные diff-обновления
        currentMemberNames = memberNames
        
        membersStack.arrangedSubviews.forEach { arrangedSubview in
            membersStack.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        
        memberNames.forEach { memberName in
            // Используем тот же ItemCell, чтобы список визуально совпадал с settings-экраном
            let cell = ItemCell(image: UIImage(systemName: Constants.memberIcon))
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.isUserInteractionEnabled = false
            cell.text = memberName
            cell.baseColor = membersBaseColor
            cell.tintColor = membersTintColor
            cell.textColor = membersTextColor
            
            cell.heightAnchor.constraint(equalToConstant: Constants.cellsHeight).isActive = true
            membersStack.addArrangedSubview(cell)
        }
    }
    
    private func updateAvatarImage(_ image: UIImage?) {
        // Если своего изображения нет, остаётся стандартный placeholder для чата
        let resolvedImage = image ?? Constants.placeholderAvatar
        
        guard avatar.window != nil else {
            avatar.image = resolvedImage
            return
        }
        
        UIView.transition(
            with: avatar,
            duration: Constants.updateDuration,
            options: .transitionCrossDissolve
        ) {
            self.avatar.image = resolvedImage
        }
    }
}

extension ChatInfoController: ChatInfoDisplayLogic {
    typealias Model = ChatInfoModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Получаем нужные цвета в виде UIColor
        let bgColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradientColor = UIColor(hex: viewModel.bgGradient.hex, alpha: viewModel.bgGradient.a)
        let elementsBaseColor = UIColor(hex: viewModel.elementsBase.hex, alpha: viewModel.elementsBase.a)
        let tintColor = UIColor(hex: viewModel.tint.hex, alpha: viewModel.tint.a)
        let textColor = UIColor(hex: viewModel.textColor.hex, alpha: viewModel.textColor.a)
        
        // Фон
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        
        // Кнопка назад
        backButton.baseColor = elementsBaseColor
        backButton.tintColor = tintColor
        
        // Аватар + название чата
        avatar.baseColor = elementsBaseColor
        chatTitle.textColor = textColor
        
        // Список участников
        membersBaseColor = elementsBaseColor
        membersTintColor = tintColor
        membersTextColor = textColor
        updateMemberCells(with: currentMemberNames)
    }
    
    func displayChatData(_ viewModel: Model.GetChatData.ViewModel) {
        // Так как если window == nil то при transition могут быть видны артефакты
        if chatTitle.window != nil {
            UIView.transition(
                with: chatTitle,
                duration: Constants.updateDuration,
                options: .transitionCrossDissolve
            ) {
                self.chatTitle.text = viewModel.title
            }
        } else {
            chatTitle.text = viewModel.title
        }
        
        // Пока аватар загружается — держим shimmer поверх placeholder
        if viewModel.isAvatarLoading {
            if avatarOverlay.superview == nil {
                avatarOverlay.show(over: avatar)
            }
        } else {
            avatarOverlay.hide()
            updateAvatarImage(
                viewModel.avatarData.flatMap(UIImage.init(data:))
            )
        }
        
        // Нет смысла пересобирать стек если состав не менялся
        guard currentMemberNames != viewModel.memberNames else { return }
        updateMemberCells(with: viewModel.memberNames)
    }
    
    func displayError(_ viewModel: Model.ShowError.ViewModel) {
        // Показываем alert
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
