//
//  UserChatsController.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import UIKit

final class UserChatsController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let horisontalInset: CGFloat = 22
        
        static let emptyStateText = "No chats yet"
        static let bottomInset: CGFloat = 120
        
        static let containerTop: CGFloat = 18
        static let containerHeight: CGFloat = 200
        
        static let tableTop: CGFloat = 10
        static let paginationMultiplier: CGFloat = 1.5
        static let emptyTableLabelFont: CGFloat = 17
        
        static let headerCoverLiftFactor: CGFloat = 0.22
        static let headerTop: CGFloat = -30
        
        static let placeholderAvatar = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    private typealias Section = Int
    private typealias ItemIdentifier = String
    private typealias DataSource = UITableViewDiffableDataSource<Section, ItemIdentifier>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemIdentifier>
    
    private let interactor: UserChatsBusinessLogic
    private let tableDataProvider: UserChatsTableDataLogic
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateLabel = UILabel()
    
    private let headerView = HeaderView()
    private let containerView = TableContainerView()
    
    private lazy var dataSource = makeDataSource()
    
    // Констрейнты хэдера
    lazy private var headerTopConstraint = headerView.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor,
        constant: Constants.headerTop
    )
    // Констрейнты контейнера
    lazy private var containerTopConstraint = containerView.topAnchor.constraint(equalTo: view.topAnchor)
    
    // Базовая y-координата нижней границы шапки относительно верха экрана
    lazy private var headerBottomY: CGFloat = view.safeAreaInsets.top + Constants.headerTop + HeaderView.preferredHeight
    // Базовая y-координата контейнера относительно верха экрана
    lazy private var baseContainerTopY: CGFloat = headerBottomY + Constants.containerTop
    
    // MARK: Lifecycle
    
    init(
        interactor: UserChatsBusinessLogic,
        tableDataProvider: UserChatsTableDataLogic
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
        headerView.showAvatarLoading()
        interactor.listenCurrentUserAvatar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncChatsStateFromProviderIfNeeded()
        interactor.loadInitialChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerView.hideAvatarLoading()
        interactor.stopListeningCurrentUserAvatar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderAndContainerLayoutIfNeeded()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        configureTableView()
        configureHeader()
        configureContainer()
        view.bringSubviewToFront(tableView)
    }
    
    private func configureTableView() {
        emptyStateLabel.text = Constants.emptyStateText
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = .systemFont(
            ofSize: Constants.emptyTableLabelFont,
            weight: .medium
        )
        emptyStateLabel.backgroundColor = .clear
        emptyStateLabel.isHidden = true
        
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset.bottom = Constants.bottomInset
        tableView.register(
            ChatItemCell.self,
            forCellReuseIdentifier: ChatItemCell.reuseIdentifier
        )
        tableView.backgroundView = emptyStateLabel
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                tableView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: Constants.horisontalInset
                ),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ]
        )
    }
    
    private func configureHeader() {
        headerView.showAvatarLoading()
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        NSLayoutConstraint.activate(
            [
                headerTopConstraint,
                headerView.heightAnchor.constraint(equalToConstant: HeaderView.preferredHeight),
                headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horisontalInset),
                headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horisontalInset)
            ]
        )
    }
    
    private func configureContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerTopConstraint,
            containerView.heightAnchor.constraint(equalToConstant: Constants.containerHeight),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: Update header and container layout
    
    private func updateHeaderAndContainerLayoutIfNeeded() {
        guard headerBottomY > 0 else { return }
        containerTopConstraint.constant = baseContainerTopY
        
        if tableView.contentInset.top == 0 {
            let topInset = baseContainerTopY + Constants.tableTop
            tableView.contentInset.top = topInset
            tableView.contentOffset.y = -topInset
        }
        
        updateHeaderAndContainerForScroll()
    }
    
    private func normalizedContentOffset(for scrollView: UIScrollView) -> CGFloat {
        // Приводим offset к системе координат "0 = список стоит в верхней точке"
        max(0, scrollView.contentOffset.y + scrollView.adjustedContentInset.top)
    }
    
    private func overscrollOffset(for scrollView: UIScrollView) -> CGFloat {
        // Отдельно вычисляем pull-down overscroll: это положительное значение только
        // когда пользователь тащит список вниз дальше стартовой точки.
        max(0, -(scrollView.contentOffset.y + scrollView.adjustedContentInset.top))
    }
    
    private func updateHeaderAndContainerForScroll() {
        guard headerBottomY > 0 else { return }

        let scrollOffset = normalizedContentOffset(for: tableView)
        let overscroll = overscrollOffset(for: tableView)

        let containerTopOnScreen = baseContainerTopY - scrollOffset

        // Первая фаза — пока container только доезжает до top = 0.
        let coverDistance = baseContainerTopY
        let cover = max(0, min(coverDistance, max(scrollOffset, 0)))

        // Вторая фаза начинается после того, как container уже дошёл до верхнего края и продолжил движение выше экрана.
        let collapse = max(0, -containerTopOnScreen)

        // Итоговая экранная позиция контейнера: обычный скролл поднимает его вверх, а pull-down overscroll опускает вниз.
        let currentContainerTopY = containerTopOnScreen + overscroll

        // Header сжимается только пока идёт фаза cover, то есть пока container его накрывает.
        let recessionProgress = coverDistance == 0 ? 0 : min(cover / coverDistance, 1)
        
        let headerLift = collapse + cover * Constants.headerCoverLiftFactor
        
        containerTopConstraint.constant = currentContainerTopY
        headerTopConstraint.constant = Constants.headerTop - headerLift
        headerView.setCompressionProgress(recessionProgress)
    }
}

// MARK: - Display logic

extension UserChatsController: UserChatsDisplayLogic {
    typealias Model = UserChatsModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Получаем нужные цвета
        let bg = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradient = UIColor(hex: viewModel.bgGradient.hex, alpha: viewModel.bgGradient.a)
        let base = UIColor(hex: viewModel.elementsBase.hex, alpha: viewModel.elementsBase.a)
        let textColor = UIColor(hex: viewModel.textColor.hex, alpha: viewModel.textColor.a)
        
        view.backgroundColor = bg
        
        headerView.baseColor = base
        headerView.textColor = textColor
        
        containerView.fillColor = bg
        containerView.glowColor = bgGradient
    }
    
    func displayCurrentUserAvatar(_ viewModel: Model.CurrentUserAvatar.ViewModel) {
        headerView.hideAvatarLoading()
        let image = viewModel.avatarData
            .flatMap(UIImage.init(data:))
            ?? Constants.placeholderAvatar
        headerView.setAvatarImage(image, animated: true)
    }
    
    func displayChats(_ viewModel: Model.ChatsList.ViewModel) {
        emptyStateLabel.isHidden = !viewModel.items.isEmpty
        
        guard view.window != nil else { return }
        
        applyChatsState(
            chatIds: viewModel.items.map { $0.id },
            updatedChatIds: viewModel.updatedChatIds,
            animatingDifferences: true
        )
    }
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel) {
        guard view.window != nil else { return }
        
        var snapshot = dataSource.snapshot()
        guard snapshot.indexOfItem(viewModel.chatId) != nil else { return }
        snapshot.reloadItems([viewModel.chatId])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func displayError(_ viewModel: Model.ShowError.ViewModel) {
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

// MARK: - UITableView

extension UserChatsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatId = dataSource.itemIdentifier(for: indexPath),
              let item = tableDataProvider.item(for: chatId) else {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        interactor.loadChatMessagesScreen(
            chatId: chatId,
            chatTitle: item.title,
            chatAvatarURL: item.avatarURL
        )
    }
    
    // Отслеживание скролла для пагинации
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderAndContainerForScroll()
        view.layoutIfNeeded()
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        guard contentHeight > 0 else { return }
        
        if offsetY > contentHeight - height * Constants.paginationMultiplier {
            interactor.loadNextPage()
        }
    }
    
    // MARK: Factory methods
    
    private func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { [weak self] tableView, indexPath, chatId in
            guard let self,
                  let item = self.tableDataProvider.item(for: chatId) else {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ChatItemCell.reuseIdentifier,
                for: indexPath
            )
            
            guard let chatCell = cell as? ChatItemCell else {
                return cell
            }
            
            self.configure(chatCell, with: item)
            return cell
        }
    }
    
    private func makeSnapshot(chatIds: [String]) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(chatIds, toSection: 0)
        return snapshot
    }
    
    // MARK: Chats state
    
    // Пока экран скрыт за ChatMessages, presenter продолжает обновляться,
    // а сама таблица эти апдейты пропускает. При возврате синхронизируемся
    // из уже готового состояния presenter без нового запроса.
    private func syncChatsStateFromProviderIfNeeded() {
        let chatIds = tableDataProvider.chatIds()
        emptyStateLabel.isHidden = !chatIds.isEmpty
        
        let currentChatIds = dataSource.snapshot().itemIdentifiers
        if currentChatIds != chatIds {
            dataSource.apply(
                makeSnapshot(chatIds: chatIds),
                animatingDifferences: false
            )
        }
        
        guard !chatIds.isEmpty else { return }
        
        var snapshot = dataSource.snapshot()
        let reloadableChatIds = chatIds.filter {
            snapshot.indexOfItem($0) != nil
        }
        guard !reloadableChatIds.isEmpty else { return }
        
        snapshot.reloadItems(reloadableChatIds)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // Назначение нового состояния ячейкам
    private func applyChatsState(
        chatIds: [String],
        updatedChatIds: [String],
        animatingDifferences: Bool
    ) {
        dataSource.apply(
            makeSnapshot(chatIds: chatIds),
            animatingDifferences: animatingDifferences
        )
        
        guard updatedChatIds.isEmpty == false else { return }
        
        var snapshot = dataSource.snapshot()
        let reloadableChatIds = updatedChatIds.filter {
            snapshot.indexOfItem($0) != nil
        }
        guard reloadableChatIds.isEmpty == false else { return }
        
        snapshot.reloadItems(reloadableChatIds)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // Конфигурация ячейки
    private func configure(
        _ cell: ChatItemCell,
        with item: Model.ChatsList.ViewModel.ChatCell
    ) {
        cell.title = item.title
        cell.subtitle = item.subtitle
        cell.time = item.time
        cell.baseColor = UIColor(
            hex: item.baseColor.hex,
            alpha: item.baseColor.a
        )
        cell.textColor = UIColor(
            hex: item.textColor.hex,
            alpha: item.textColor.a
        )
        cell.avatarImage = item.avatarData.flatMap(UIImage.init(data:))
    }
}
