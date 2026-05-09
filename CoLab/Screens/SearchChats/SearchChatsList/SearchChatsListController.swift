//
//  SearchChatsListController.swift
//  CoLab
//
//  Created by User on 24.04.2026.
//

import UIKit

final class SearchChatsListController: UIViewController {
    typealias Model = SearchChatsListModels
    
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
        static let estimatedRowHeight: CGFloat = 196
        
        static let initialLoadingHeight: CGFloat = 56
        
        static let searchFieldCornerRadius: CGFloat = 20
        static let searchFieldFontSize: CGFloat = 18
        static let searchFieldImageSize: CGFloat = 28
        static let searchFieldImage = "magnifyingglass"
        static let searchFieldPlaceholder = "Поиск чатов"
        static let searchFieldHeight: CGFloat = 46
        static let searchHeaderTop: CGFloat = 14
        static let searchHeaderBottom: CGFloat = 16
        static let searchHeaderHeight = searchHeaderTop
            + searchFieldHeight
            + searchHeaderBottom

        static let headerCoverLiftFactor: CGFloat = 0.22
        static let headerTop: CGFloat = -30
        
        static let placeholderAvatar = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    private let interactor: SearchChatsListBusinessLogic
    private let tableDataProvider: SearchChatsListTableDataLogic
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateLabel = UILabel()
    private let searchHeaderView = UIView()
    private let searchField = ImageTextField(
        image: UIImage(systemName: Constants.searchFieldImage)
    )
    
    private let initialLoadingIndicator = UIActivityIndicatorView(style: .medium)

    private let headerView = HeaderView()
    private let containerView = TableContainerView()
    
    private var displayedChatIds: [String] = []
    private var hasLoadedChatsState = false
    private var isInitialLoadingShown = false
    
    private lazy var headerTopConstraint = headerView.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor,
        constant: Constants.headerTop
    )
    private lazy var containerTopConstraint = containerView.topAnchor.constraint(
        equalTo: view.topAnchor
    )
    
    private lazy var headerBottomY: CGFloat = view.safeAreaInsets.top
        + Constants.headerTop
        + HeaderView.preferredHeight
    private lazy var baseContainerTopY: CGFloat = headerBottomY
        + Constants.containerTop
    
    // MARK: Lifecycle
    
    init(
        interactor: SearchChatsListBusinessLogic,
        tableDataProvider: SearchChatsListTableDataLogic
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
        syncChatsStateFromProvider()
        showInitialLoadingIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncChatsStateFromProvider()
        showInitialLoadingIfNeeded()
        interactor.loadInitialChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerView.hideAvatarLoading()
        hideInitialLoading()
        interactor.stopListeningCurrentUserAvatar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderAndContainerLayoutIfNeeded()
        updateSearchHeaderFrameIfNeeded()
        updateInitialLoadingFrameIfNeeded()
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        configureTableView()
        configureHeader()
        configureContainer()
        configureKeyboardHiding()
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
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset.bottom = Constants.bottomInset
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.register(
            SearchChatItemCell.self,
            forCellReuseIdentifier: SearchChatItemCell.reuseIdentifier
        )
        tableView.backgroundView = emptyStateLabel
        configureSearchField()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        configureInitialLoading()
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureSearchField() {
        searchField.placeholder = Constants.searchFieldPlaceholder
        searchField.cornerRadius = Constants.searchFieldCornerRadius
        searchField.font = .systemFont(
            ofSize: Constants.searchFieldFontSize,
            weight: .medium
        )
        searchField.imageSize = Constants.searchFieldImageSize
        searchField.returnKeyType = .search
        searchField.onReturn = { [weak self] in
            self?.submitSearchText()
        }
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        searchHeaderView.backgroundColor = .clear
        searchHeaderView.addSubview(searchField)
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(
                equalTo: searchHeaderView.topAnchor,
                constant: Constants.searchHeaderTop
            ),
            searchField.leadingAnchor.constraint(
                equalTo: searchHeaderView.leadingAnchor
            ),
            searchField.trailingAnchor.constraint(
                equalTo: searchHeaderView.trailingAnchor
            ),
            searchField.heightAnchor.constraint(
                equalToConstant: Constants.searchFieldHeight
            )
        ])
    }
    
    private func configureKeyboardHiding() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(screenTapped)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configureHeader() {
        headerView.showAvatarLoading()
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerTopConstraint,
            headerView.heightAnchor.constraint(
                equalToConstant: HeaderView.preferredHeight
            ),
            headerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            headerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.horisontalInset
            )
        ])
    }
    
    private func configureContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerTopConstraint,
            containerView.heightAnchor.constraint(
                equalToConstant: Constants.containerHeight
            ),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureInitialLoading() {
        initialLoadingIndicator.hidesWhenStopped = true
        initialLoadingIndicator.isHidden = true
        tableView.addSubview(initialLoadingIndicator)
    }

    // MARK: Updating layout
    
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
        max(0, scrollView.contentOffset.y + scrollView.adjustedContentInset.top)
    }
    
    private func overscrollOffset(for scrollView: UIScrollView) -> CGFloat {
        max(0, -(scrollView.contentOffset.y + scrollView.adjustedContentInset.top))
    }
    
    private func updateHeaderAndContainerForScroll() {
        guard headerBottomY > 0 else { return }
        
        let scrollOffset = normalizedContentOffset(for: tableView)
        let overscroll = overscrollOffset(for: tableView)
        let containerTopOnScreen = baseContainerTopY - scrollOffset
        let coverDistance = baseContainerTopY
        let cover = max(0, min(coverDistance, max(scrollOffset, 0)))
        let collapse = max(0, -containerTopOnScreen)
        let currentContainerTopY = containerTopOnScreen + overscroll
        let recessionProgress = coverDistance == 0
            ? 0
            : min(cover / coverDistance, 1)
        let headerLift = collapse + cover * Constants.headerCoverLiftFactor
        
        containerTopConstraint.constant = currentContainerTopY
        headerTopConstraint.constant = Constants.headerTop - headerLift
        headerView.setCompressionProgress(recessionProgress)
    }
    
    private func updateSearchHeaderFrameIfNeeded() {
        guard tableView.bounds.width > 0 else { return }
        
        let targetFrame = CGRect(
            origin: .zero,
            size: CGSize(
                width: tableView.bounds.width,
                height: Constants.searchHeaderHeight
            )
        )
        
        let shouldUpdateFrame = searchHeaderView.frame != targetFrame
        let shouldInstallHeader = tableView.tableHeaderView !== searchHeaderView
        
        guard shouldUpdateFrame || shouldInstallHeader else { return }
        
        searchHeaderView.frame = targetFrame
        tableView.tableHeaderView = searchHeaderView
    }
    
    // MARK: Chats state
    
    private func syncChatsStateFromProvider() {
        let nextChatIds = tableDataProvider.chatIds()
        let shouldReload = displayedChatIds != nextChatIds
        displayedChatIds = nextChatIds

        if displayedChatIds.isEmpty {
            emptyStateLabel.isHidden = !hasLoadedChatsState || isInitialLoadingShown
        } else {
            hideInitialLoading()
            emptyStateLabel.isHidden = true
        }

        guard shouldReload else {
            refreshVisibleCells()
            return
        }
        
        tableView.reloadData()
    }
    
    private func applyChatsState(chatIds: [String], animated _: Bool) {
        let shouldReload = displayedChatIds != chatIds
        displayedChatIds = chatIds
        hideInitialLoading()
        emptyStateLabel.isHidden = !hasLoadedChatsState || !chatIds.isEmpty
        
        guard shouldReload else {
            refreshVisibleCells()
            return
        }
        
        UIView.performWithoutAnimation {
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
    }

    // Лоадер находится внутри таблицы, чтобы двигаться вместе с контентом
    // и оставаться на месте первой ячейки.
    private func showInitialLoadingIfNeeded() {
        guard !isInitialLoadingShown else { return }
        guard !hasLoadedChatsState else { return }
        guard displayedChatIds.isEmpty else { return }

        isInitialLoadingShown = true
        emptyStateLabel.isHidden = true
        updateInitialLoadingFrameIfNeeded()
        tableView.bringSubviewToFront(initialLoadingIndicator)
        initialLoadingIndicator.startAnimating()
    }

    private func hideInitialLoading() {
        guard isInitialLoadingShown else { return }

        isInitialLoadingShown = false
        initialLoadingIndicator.stopAnimating()
    }

    private func updateInitialLoadingFrameIfNeeded() {
        guard isInitialLoadingShown else { return }

        initialLoadingIndicator.center = CGPoint(
            x: tableView.bounds.midX,
            y: Constants.searchHeaderHeight + Constants.initialLoadingHeight / 2
        )
        tableView.bringSubviewToFront(initialLoadingIndicator)
    }
    
    // MARK: Actions
    
    @objc
    private func screenTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: searchField)
        guard !searchField.bounds.contains(location) else { return }
        
        view.endEditing(true)
    }
    
    private func submitSearchText() {
        interactor.updateSearchText(searchField.text ?? "")
    }
    
    private func configure(
        _ cell: SearchChatItemCell,
        with item: Model.ChatsList.ViewModel.ChatCell
    ) {
        cell.title = item.title
        cell.chatDescription = item.description ?? ""
        cell.baseColor = UIColor(hex: item.baseColor.hex, alpha: item.baseColor.a)
        cell.textColor = UIColor(hex: item.textColor.hex, alpha: item.textColor.a)
        cell.gradientStartColor = UIColor(
            hex: item.startGradientColor.hex,
            alpha: item.startGradientColor.a
        )
        cell.gradientEndColor = UIColor(
            hex: item.endGradientColor.hex,
            alpha: item.endGradientColor.a
        )
        cell.avatarImage = item.avatarData.flatMap(UIImage.init(data:))
        cell.isAvatarLoading = item.isAvatarLoading
    }
    
    private func refreshVisibleCells() {
        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            guard displayedChatIds.indices.contains(indexPath.row),
                  let item = tableDataProvider.item(
                    for: displayedChatIds[indexPath.row]
                  ),
                  let cell = tableView.cellForRow(
                    at: indexPath
                  ) as? SearchChatItemCell else {
                return
            }
            
            configure(cell, with: item)
        }
    }
}

// MARK: Display logic extension

extension SearchChatsListController: SearchChatsListDisplayLogic {
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        let bg = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradient = UIColor(
            hex: viewModel.bgGradient.hex,
            alpha: viewModel.bgGradient.a
        )
        let base = UIColor(
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
        
        view.backgroundColor = bg
        
        headerView.baseColor = base
        headerView.textColor = textColor
        initialLoadingIndicator.color = textColor
        
        containerView.fillColor = bg
        containerView.glowColor = bgGradient
        
        searchField.baseColor = base
        searchField.tintColor = tintColor
        searchField.textColor = textColor
    }
    
    func displayCurrentUserAvatar(_ viewModel: Model.CurrentUserAvatar.ViewModel) {
        headerView.hideAvatarLoading()
        let image = viewModel.avatarData
            .flatMap(UIImage.init(data:))
            ?? Constants.placeholderAvatar
        headerView.setAvatarImage(image, animated: true)
    }
    
    func displayChats(_ viewModel: Model.ChatsList.ViewModel) {
        hasLoadedChatsState = true
        hideInitialLoading()
        guard view.window != nil else { return }
        
        applyChatsState(
            chatIds: viewModel.items.map { $0.id },
            animated: true
        )
    }
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel) {
        guard view.window != nil else { return }
        guard let row = displayedChatIds.firstIndex(of: viewModel.chatId) else {
            return
        }
        let indexPath = IndexPath(row: row, section: 0)
        guard let item = tableDataProvider.item(for: viewModel.chatId),
              let cell = tableView.cellForRow(
                at: indexPath
              ) as? SearchChatItemCell else {
            return
        }
        
        configure(cell, with: item)
    }
    
    func displayError(_ viewModel: Model.ShowError.ViewModel) {
        hideInitialLoading()

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

// MARK: Table data source extension

extension SearchChatsListController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        displayedChatIds.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard displayedChatIds.indices.contains(indexPath.row),
              let item = tableDataProvider.item(
                for: displayedChatIds[indexPath.row]
              ) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchChatItemCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let chatCell = cell as? SearchChatItemCell else {
            return cell
        }
        
        configure(chatCell, with: item)
        return chatCell
    }
}

// MARK: Table delegate extension

extension SearchChatsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard displayedChatIds.indices.contains(indexPath.row),
              let item = tableDataProvider.item(
                for: displayedChatIds[indexPath.row]
              ) else {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        interactor.loadAddChatScreen(
            chatId: item.id
        )
    }
    
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
}
