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
        static let descriptionGap: CGFloat = 12
        static let avatarLabelFontSize: CGFloat = 40
        static let avatarLabelLines = 2
        static let headerBottomInset: CGFloat = 55
        static let bottomInset: CGFloat = 24
        static let updateDuration = 0.25
        
        static let unknownTitle = "..."
        static let emptyStateText = "Участников нет"
        static let estimatedRowHeight: CGFloat = 80
        
        static let placeholderAvatar = UIImage(systemName: "person")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    private typealias Section = Int
    private typealias ItemIdentifier = String
    private typealias DataSource = UITableViewDiffableDataSource<Section, ItemIdentifier>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemIdentifier>
    
    private let interactor: ChatInfoBusinessLogic
    private let tableDataProvider: ChatInfoTableDataLogic
    
    private let backgroundView = MainBackgroundView()
    private let backButton = BackNavBarButton()
    
    private let scrollView = UIScrollView()
    
    private let avatarOverlay = LoadingOverlay()
    private let avatar = CircleImage(Constants.placeholderAvatar)
    private let chatTitle = UILabel()
    private let chatDescription = ChatDescriptionView()
    private let headerTextStackView = UIStackView()
    
    private let emptyStateLabel = UILabel()
    private let tableView = ContentSizedTableView(frame: .zero, style: .plain)
    private lazy var dataSource = makeDataSource()
    
    private var avatarTopConstraint: NSLayoutConstraint?
    private var tableBottomConstraint: NSLayoutConstraint?
    
    // MARK: Lifecycle
    
    init(
        interactor: ChatInfoBusinessLogic,
        tableDataProvider: ChatInfoTableDataLogic
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // Так как не можем во время viewDidLoad поставить корректные отступы
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateInsetConstraints()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        
        configureScrollView()
        configureBackButton()
        configureHeader()
        configureMembers()
        updateInsetConstraints()
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
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
                self?.navigationController?.popViewController(animated: true)
            },
            for: .touchUpInside
        )
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -Constants.backToUnsafe)
        ])
    }
    
    private func configureHeader() {
        avatarOverlay.show(over: avatar)
        
        chatTitle.numberOfLines = Constants.avatarLabelLines
        chatTitle.font = .systemFont(
            ofSize: Constants.avatarLabelFontSize,
            weight: .medium
        )
        chatTitle.text = Constants.unknownTitle
        chatTitle.textAlignment = .center

        chatDescription.isHidden = true
        
        headerTextStackView.axis = .vertical
        headerTextStackView.spacing = Constants.descriptionGap
        headerTextStackView.alignment = .fill
        headerTextStackView.translatesAutoresizingMaskIntoConstraints = false
        headerTextStackView.addArrangedSubview(chatTitle)
        headerTextStackView.addArrangedSubview(chatDescription)

        avatar.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(avatar)
        scrollView.addSubview(headerTextStackView)
        
        avatarTopConstraint = avatar.topAnchor.constraint(
            equalTo: scrollView.contentLayoutGuide.topAnchor
        )
        avatarTopConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            avatar.heightAnchor.constraint(
                equalToConstant: Constants.avatarSize
            ),
            avatar.widthAnchor.constraint(
                equalToConstant: Constants.avatarSize
            ),
            avatar.centerXAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.centerXAnchor
            ),
            
            headerTextStackView.topAnchor.constraint(
                equalTo: avatar.bottomAnchor,
                constant: Constants.avatarGap
            ),
            headerTextStackView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            headerTextStackView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -Constants.horisontalInset
            )
        ])
    }
    
    private func configureMembers() {
        emptyStateLabel.text = Constants.emptyStateText
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = .systemFont(ofSize: 17, weight: .medium)
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.backgroundColor = .clear
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        scrollView.addSubview(emptyStateLabel)
        
        tableBottomConstraint = tableView.bottomAnchor.constraint(
            equalTo: scrollView.contentLayoutGuide.bottomAnchor
        )
        tableBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: headerTextStackView.bottomAnchor,
                constant: Constants.headerBottomInset
            ),
            tableView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            tableView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -Constants.horisontalInset
            ),
            tableView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Constants.estimatedRowHeight
            ),
            
            emptyStateLabel.leadingAnchor.constraint(
                equalTo: tableView.leadingAnchor
            ),
            emptyStateLabel.trailingAnchor.constraint(
                equalTo: tableView.trailingAnchor
            ),
            emptyStateLabel.centerXAnchor.constraint(
                equalTo: tableView.centerXAnchor
            ),
            emptyStateLabel.centerYAnchor.constraint(
                equalTo: tableView.centerYAnchor
            )
        ])
    }
    
    private func updateInsetConstraints() {
        avatarTopConstraint?.constant = view.safeAreaInsets.top + Constants.avatarTop
        tableBottomConstraint?.constant = -(view.safeAreaInsets.bottom + Constants.bottomInset)
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
        cell.baseColor = UIColor(
            hex: item.baseColor.hex,
            alpha: item.baseColor.a
        )
        cell.textColor = UIColor(
            hex: item.textColor.hex,
            alpha: item.textColor.a
        )
        cell.tintColor = UIColor(
            hex: item.tintColor.hex,
            alpha: item.tintColor.a
        )
        cell.avatarImage = item.avatarData.flatMap { UIImage.init(data: $0) }
    }
}

// MARK: - Display logic

extension ChatInfoController: ChatInfoDisplayLogic {
    typealias Model = ChatInfoModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Получаем нужные цвета в виде UIColor
        let bgColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradientColor = UIColor(
            hex: viewModel.bgGradient.hex,
            alpha: viewModel.bgGradient.a
        )
        let elementsBaseColor = UIColor(
            hex: viewModel.elementsBase.hex,
            alpha: viewModel.elementsBase.a
        )
        let tintColor = UIColor(
            hex: viewModel.tint.hex,
            alpha: viewModel.tint.a
        )
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
        
        // Аватар + название чата
        avatar.borderColor = elementsBaseColor
        chatTitle.textColor = textColor
        chatDescription.baseColor = elementsBaseColor
        chatDescription.textColor = textColor
        
        // Empty state
        emptyStateLabel.textColor = textColor
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
        
        let description = viewModel.description ?? ""
        let shouldShowDescription = !description.isEmpty
        chatDescription.text = description
        chatDescription.isHidden = !shouldShowDescription

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
    }
    
    func displayMembers(_ viewModel: Model.MembersList.ViewModel) {
        let hasMembers = !viewModel.items.isEmpty
        emptyStateLabel.isHidden = hasMembers
        tableView.isHidden = !hasMembers
        
        applyMembersState(
            memberIds: viewModel.items.map { $0.id },
            updatedMemberIds: viewModel.updatedMemberIds,
            animatingDifferences: true
        )
    }
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel) {
        var snapshot = dataSource.snapshot()
        guard snapshot.indexOfItem(viewModel.memberId) != nil else { return }
        
        snapshot.reloadItems([viewModel.memberId])
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.tableView.invalidateIntrinsicContentSize()
        }
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

// MARK: - UITableView

extension ChatInfoController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
