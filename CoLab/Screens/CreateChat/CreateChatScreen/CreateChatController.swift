//
//  CreateChatController.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import UIKit

final class CreateChatController: UIViewController {
    typealias Model = CreateChatModels
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let horisontalInset: CGFloat = 22
        static let backToUnsafe: CGFloat = 30
        static let bottomInset: CGFloat = 24
        
        static let avatarSize: CGFloat = 170
        static let avatarTop: CGFloat = 40
        static let avatarHintTop: CGFloat = 10
        static let avatarHintText = "Нажмите на аватар, чтобы изменить"
        static let avatarHintLines = 1
        static let avatarHintFontSize: CGFloat = 13
        static let avatarHintAlpha: CGFloat = 0.3
        
        static let fieldsTop: CGFloat = 40
        static let fieldHeight: CGFloat = 65
        static let fieldSpacing: CGFloat = 14
        static let titleFieldImage = "textformat"
        static let descriptionFieldImage = "text.alignleft"
        static let titleFieldPlaceholder = "Название чата"
        static let descriptionFieldPlaceholder = "Описание чата"
        
        static let visibilityTop: CGFloat = 18
        static let visibilityHeight: CGFloat = 60
        
        static let membersTop: CGFloat = 40
        static let estimatedRowHeight: CGFloat = 80
        static let addMemberCellTop: CGFloat = 40
        static let addMemberCellHeight: CGFloat = 80
        static let addMemberCellText = "Добавить участника"
        
        static let createButtonTop: CGFloat = 20
        static let createButtonHeight: CGFloat = 55
        static let createButtonText = "Создать"
        
        static let updateDuration: TimeInterval = 0.25
        static let photoCompressionQuality: CGFloat = 0.1
        static let alertOk = "Ok"
        
        static let placeholderAvatar = UIImage(systemName: "person")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    private typealias Section = Int
    private typealias ItemIdentifier = String
    private typealias DataSource = UITableViewDiffableDataSource<Section, ItemIdentifier>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemIdentifier>
    
    private let interactor: CreateChatBusinessLogic
    private let tableDataProvider: CreateChatTableDataLogic
    
    private let overlay = LoadingOverlay()
    private let backgroundView = MainBackgroundView()
    private let scrollView = UIScrollView()
    private let backButton = BackNavBarButton()
    
    private let avatar = CircleImage(Constants.placeholderAvatar)
    private let avatarHintLabel = UILabel()
    private let titleField = ImageTextField(
        image: UIImage(systemName: Constants.titleFieldImage)
    )
    private let descriptionField = ImageTextField(
        image: UIImage(systemName: Constants.descriptionFieldImage)
    )
    private let visibilitySwitch = ChatVisibilitySwitchView()
    private let tableView = ContentSizedTableView(frame: .zero, style: .plain)
    private lazy var dataSource = makeDataSource()
    private let addMemberCell = ItemCell()
    private let createButton = FilledGradientButton()
    
    private var isAvatarChanged = false
    private var isFormValid = false
    private var isCreating = false
    private var avatarTopConstraint: NSLayoutConstraint?
    private var backButtonTopConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var modalTopSafeAreaCompensation: CGFloat = 0
    
    private lazy var avatarPicker = ImagePicker(
        presentingViewController: self,
        onImagePicked: { [weak self] image in
            self?.applySelectedAvatar(image)
        }
    )
    
    // MARK: Lifecycle
    
    init(
        interactor: CreateChatBusinessLogic,
        tableDataProvider: CreateChatTableDataLogic
    ) {
        self.interactor = interactor
        self.tableDataProvider = tableDataProvider
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
        interactor.loadDefaultAvatar()
        interactor.loadCurrentUser()
        validate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overlay.hide()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateInsetConstraints()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        configureScrollView()
        configureBackButton()
        configureAvatar()
        configureFields()
        configureVisibilitySwitch()
        configureMembers()
        configureAddMemberButton()
        configureCreateButton()
        configureKeyboardDismissal()
        updateInsetConstraints()
    }
    
    private func configureScrollView() {
        scrollView.delaysContentTouches = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addAction(
            UIAction { [weak self] _ in
                self?.interactor.loadGoBack()
            },
            for: .touchUpInside
        )
        view.addSubview(backButton)
        
        let topConstraint = backButton.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: -Constants.backToUnsafe + modalTopSafeAreaCompensation
        )
        backButtonTopConstraint = topConstraint
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            topConstraint
        ])
    }
    
    private func configureAvatar() {
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(avatarTapped)
            )
        )
        avatar.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(avatar)
        
        avatarHintLabel.textAlignment = .center
        avatarHintLabel.numberOfLines = Constants.avatarHintLines
        avatarHintLabel.text = Constants.avatarHintText
        avatarHintLabel.font = .systemFont(
            ofSize: Constants.avatarHintFontSize,
            weight: .medium
        )
        avatarHintLabel.alpha = Constants.avatarHintAlpha
        avatarHintLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(avatarHintLabel)
        
        avatarTopConstraint = avatar.topAnchor.constraint(
            equalTo: scrollView.contentLayoutGuide.topAnchor
        )
        avatarTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            avatar.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatar.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatar.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            
            avatarHintLabel.topAnchor.constraint(
                equalTo: avatar.bottomAnchor,
                constant: Constants.avatarHintTop
            ),
            avatarHintLabel.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            avatarHintLabel.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -Constants.horisontalInset
            )
        ])
    }
    
    private func configureFields() {
        titleField.placeholder = Constants.titleFieldPlaceholder
        descriptionField.placeholder = Constants.descriptionFieldPlaceholder
        titleField.returnKeyType = .next
        descriptionField.returnKeyType = .done
        titleField.onReturn = { [weak self] in
            self?.descriptionField.becomeFirstResponder()
        }
        descriptionField.onReturn = { [weak self] in
            self?.view.endEditing(true)
        }
        
        [titleField, descriptionField].forEach { field in
            field.addTarget(
                self,
                action: #selector(textDidChange),
                for: .editingChanged
            )
            field.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(field)
        }
        
        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(
                equalTo: avatarHintLabel.bottomAnchor,
                constant: Constants.fieldsTop
            ),
            titleField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            titleField.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            titleField.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -Constants.horisontalInset
            ),
            
            descriptionField.topAnchor.constraint(
                equalTo: titleField.bottomAnchor,
                constant: Constants.fieldSpacing
            ),
            descriptionField.heightAnchor.constraint(equalToConstant: Constants.fieldHeight),
            descriptionField.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            descriptionField.trailingAnchor.constraint(equalTo: titleField.trailingAnchor)
        ])
    }
    
    private func configureVisibilitySwitch() {
        visibilitySwitch.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(visibilitySwitch)
        
        NSLayoutConstraint.activate([
            visibilitySwitch.topAnchor.constraint(
                equalTo: descriptionField.bottomAnchor,
                constant: Constants.visibilityTop
            ),
            visibilitySwitch.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            visibilitySwitch.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            visibilitySwitch.heightAnchor.constraint(
                equalToConstant: Constants.visibilityHeight
            )
        ])
    }
    
    private func configureMembers() {
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = .zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.setContentHuggingPriority(.required, for: .vertical)
        tableView.setContentCompressionResistancePriority(
            .required,
            for: .vertical
        )
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            UserInfoCell.self,
            forCellReuseIdentifier: UserInfoCell.reuseIdentifier
        )
        scrollView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: visibilitySwitch.bottomAnchor,
                constant: Constants.membersTop
            ),
            tableView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            tableView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Constants.estimatedRowHeight
            )
        ])
    }
    
    private func configureAddMemberButton() {
        addMemberCell.addAction(
            UIAction { [weak self] _ in
                self?.interactor.loadAddMemberScreen()
            },
            for: .touchUpInside
        )
        addMemberCell.text = Constants.addMemberCellText
        addMemberCell.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(addMemberCell)
        
        NSLayoutConstraint.activate([
            addMemberCell.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            addMemberCell.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            addMemberCell.topAnchor.constraint(
                equalTo: tableView.bottomAnchor,
                constant: Constants.addMemberCellTop
            ),
            addMemberCell.heightAnchor.constraint(
                equalToConstant: Constants.addMemberCellHeight
            )
        ])
    }
    
    private func configureCreateButton() {
        createButton.setTitle(Constants.createButtonText, for: .normal)
        createButton.isEnabled = false
        createButton.addAction(
            UIAction { [weak self] _ in
                self?.createButtonTapped()
            },
            for: .touchUpInside
        )
        createButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(createButton)
        
        bottomConstraint = createButton.bottomAnchor.constraint(
            equalTo: scrollView.contentLayoutGuide.bottomAnchor
        )
        bottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(
                equalTo: addMemberCell.bottomAnchor,
                constant: Constants.createButtonTop
            ),
            createButton.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            createButton.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            createButton.heightAnchor.constraint(
                equalToConstant: Constants.createButtonHeight
            )
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
    
    // MARK: Factory methods
    
    private func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { [weak self] tableView, indexPath, memberId in
            guard let self,
                  let item = self.tableDataProvider.item(for: memberId) else {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: UserInfoCell.reuseIdentifier,
                for: indexPath
            )
            
            guard let userCell = cell as? UserInfoCell else {
                return cell
            }
            
            self.configure(userCell, with: item)
            return userCell
        }
    }
    
    private func makeSnapshot(memberIds: [String]) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(memberIds, toSection: 0)
        return snapshot
    }
    
    // MARK: Members state
    
    private func applyMembersState(
        memberIds: [String],
        updatedMemberIds: [String],
        animatingDifferences: Bool
    ) {
        dataSource.apply(
            makeSnapshot(memberIds: memberIds),
            animatingDifferences: animatingDifferences
        ) { [weak self] in
            self?.tableView.invalidateIntrinsicContentSize()
        }
        
        guard !updatedMemberIds.isEmpty else { return }
        
        var snapshot = dataSource.snapshot()
        let reloadableMemberIds = updatedMemberIds.filter {
            snapshot.indexOfItem($0) != nil
        }
        guard !reloadableMemberIds.isEmpty else { return }
        
        snapshot.reloadItems(reloadableMemberIds)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.tableView.invalidateIntrinsicContentSize()
        }
    }
    
    private func configure(
        _ cell: UserInfoCell,
        with item: Model.MembersList.ViewModel.MemberCell
    ) {
        cell.title = item.username
        cell.baseColor = UIColor(hex: item.baseColor.hex, alpha: item.baseColor.a)
        cell.textColor = UIColor(hex: item.textColor.hex, alpha: item.textColor.a)
        cell.tintColor = UIColor(hex: item.tintColor.hex, alpha: item.tintColor.a)
        cell.avatarImage = item.avatarData.flatMap(UIImage.init(data:))
        cell.isAvatarLoading = item.isAvatarLoading
    }
    
    // MARK: Validation
    
    private func validate() {
        interactor.loadDataValidation(
            Model.Validation.Request(
                title: titleField.text ?? "",
                description: descriptionField.text ?? ""
            )
        )
    }
    
    private func updateCreateButtonState() {
        createButton.isEnabled = isFormValid && !isCreating
    }
    
    private func updateInsetConstraints() {
        avatarTopConstraint?.constant = view.safeAreaInsets.top + Constants.avatarTop
        bottomConstraint?.constant = -(view.safeAreaInsets.bottom + Constants.bottomInset)
    }
    
    // MARK: Actions
    
    private func createButtonTapped() {
        view.endEditing(true)
        
        let avatarData = isAvatarChanged
            ? avatar.image?.jpegData(compressionQuality: Constants.photoCompressionQuality)
            : nil
        
        interactor.createChat(
            Model.CreateChat.Request(
                title: titleField.text ?? "",
                description: descriptionField.text ?? "",
                isPublic: visibilitySwitch.isPublic,
                avatarData: avatarData
            )
        )
    }
    
    private func applySelectedAvatar(_ image: UIImage) {
        isAvatarChanged = true
        
        // Так как если window == nil то при transition могут быть видны артефакты
        if avatar.window != nil {
            UIView.transition(
                with: avatar,
                duration: Constants.updateDuration,
                options: .transitionCrossDissolve
            ) {
                self.avatar.image = image
            }
        } else {
            avatar.image = image
        }
    }
    
    @objc
    private func avatarTapped() {
        avatarPicker.present()
    }
    
    @objc
    private func textDidChange() {
        validate()
    }
    
    @objc
    private func screenTapped() {
        view.endEditing(true)
    }
}

// MARK: - Display logic

extension CreateChatController: CreateChatDisplayLogic {
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Получаем нужные цвета в виде UIColor
        let bgColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradientColor = UIColor(
            hex: viewModel.bgGradient.hex,
            alpha: viewModel.bgGradient.a
        )
        let firstGradient = UIColor(
            hex: viewModel.firstGradient.hex,
            alpha: viewModel.firstGradient.a
        )
        let secondGradient = UIColor(
            hex: viewModel.secondGradient.hex,
            alpha: viewModel.secondGradient.a
        )
        let elementsBaseColor = UIColor(
            hex: viewModel.elementsBase.hex,
            alpha: viewModel.elementsBase.a
        )
        let tintColor = UIColor(hex: viewModel.tint.hex, alpha: viewModel.tint.a)
        let textColor = UIColor(
            hex: viewModel.textColor.hex,
            alpha: viewModel.textColor.a
        )
        
        // Фон
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        
        // Кнопка назад
        backButton.baseColor = elementsBaseColor
        backButton.tintColor = tintColor
        
        // Аватар
        avatar.borderColor = elementsBaseColor
        avatarHintLabel.textColor = textColor
        
        // Поля ввода
        [titleField, descriptionField].forEach { field in
            field.baseColor = elementsBaseColor
            field.textColor = textColor
            field.tintColor = tintColor
        }
        
        // Переключатель приватности
        visibilitySwitch.baseColor = elementsBaseColor
        visibilitySwitch.textColor = textColor
        
        // Кнопка добавления участника
        addMemberCell.baseColor = elementsBaseColor
        addMemberCell.textColor = textColor
        addMemberCell.tintColor = tintColor
        
        // Кнопка создания
        createButton.startColor = firstGradient
        createButton.endColor = secondGradient
    }
    
    func displayMembers(_ viewModel: Model.MembersList.ViewModel) {
        let memberIds = viewModel.items.map { $0.id }
        tableView.isHidden = memberIds.isEmpty
        applyMembersState(
            memberIds: memberIds,
            updatedMemberIds: viewModel.updatedMemberIds,
            animatingDifferences: true
        )
        validate()
    }
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel) {
        var snapshot = dataSource.snapshot()
        guard snapshot.indexOfItem(viewModel.memberId) != nil else { return }
        
        snapshot.reloadItems([viewModel.memberId])
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.tableView.invalidateIntrinsicContentSize()
        }
    }
    
    func displayChatAvatar(_ viewModel: Model.ChatAvatar.ViewModel) {
        // Если пользователь уже выбрал аватар вручную, стандартный аватар не перетираем
        guard !isAvatarChanged else { return }
        
        avatar.image = viewModel.avatarData.flatMap(UIImage.init(data:))
            ?? Constants.placeholderAvatar
    }
    
    func displayDataValidation(_ viewModel: Model.Validation.ViewModel) {
        isFormValid = viewModel.isValid
        updateCreateButtonState()
    }
    
    func displayCreatingState(_ viewModel: Model.CreatingState.ViewModel) {
        isCreating = viewModel.isCreating
        updateCreateButtonState()
        
        // Накладываем поверх эффект загрузки
        if viewModel.isCreating, let window = UIApplication.shared.currentKeyWindow {
            overlay.show(over: window)
        } else {
            overlay.hide()
        }
    }
    
    func displayError(_ viewModel: Model.ShowError.ViewModel) {
        overlay.hide()
        
        guard presentedViewController == nil else { return }
        
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

// MARK: - UITableView

extension CreateChatController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memberIds = tableDataProvider.memberIds()
        guard memberIds.indices.contains(indexPath.row) else { return }
        
        tableView.deselectRow(at: indexPath, animated: false)
        interactor.loadUserInfoScreen(userId: memberIds[indexPath.row])
    }
}

// MARK: - ModalTopSafeAreaCompensating

extension CreateChatController: ModalTopSafeAreaCompensating {
    func setModalTopSafeAreaCompensation(_ value: CGFloat) {
        modalTopSafeAreaCompensation = value
        backButtonTopConstraint?.constant = -Constants.backToUnsafe + value
    }
}
