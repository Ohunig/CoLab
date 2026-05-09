//
//  AddChatMemberController.swift
//  CoLab
//
//  Created by User on 07.05.2026.
//

import UIKit

final class AddChatMemberController: UIViewController {
    typealias Model = AddChatMemberModels
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let horisontalInset: CGFloat = 22
        static let backToUnsafe: CGFloat = 30
        static let titleFontSize: CGFloat = 34
        static let tableTop: CGFloat = 26
        static let bottomInset: CGFloat = 24
        static let estimatedRowHeight: CGFloat = 70
        static let emptyTableLabelFont: CGFloat = 17
        static let disabledTableAlpha: CGFloat = 0.5
        static let enabledTableAlpha: CGFloat = 1
        
        static let title = "Друзья"
        static let emptyStateText = "Друзей для добавления нет"
    }
    
    private let interactor: AddChatMemberBusinessLogic
    private let tableDataProvider: AddChatMemberTableDataLogic
    
    private let backgroundView = MainBackgroundView()
    private let backButton = BackNavBarButton()
    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateLabel = UILabel()
    private let initialLoadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private var displayedUserIds: [String] = []
    private var hasLoadedFriendsState = false
    
    // MARK: Lifecycle
    
    init(
        interactor: AddChatMemberBusinessLogic,
        tableDataProvider: AddChatMemberTableDataLogic
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
        showInitialLoading()
        interactor.loadStart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        configureBackButton()
        configureTitle()
        configureTableView()
        configureInitialLoading()
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
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: -Constants.backToUnsafe
            )
        ])
    }
    
    private func configureTitle() {
        titleLabel.text = Constants.title
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(
            ofSize: Constants.titleFontSize,
            weight: .medium
        )
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
        tableView.delaysContentTouches = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset.bottom = Constants.bottomInset
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.backgroundView = emptyStateLabel
        tableView.register(
            SearchFriendItemCell.self,
            forCellReuseIdentifier: SearchFriendItemCell.reuseIdentifier
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Constants.tableTop
            ),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horisontalInset
            ),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureInitialLoading() {
        initialLoadingIndicator.hidesWhenStopped = true
        initialLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(initialLoadingIndicator)
        
        NSLayoutConstraint.activate([
            initialLoadingIndicator.centerXAnchor.constraint(
                equalTo: tableView.centerXAnchor
            ),
            initialLoadingIndicator.centerYAnchor.constraint(
                equalTo: tableView.centerYAnchor
            )
        ])
    }
    
    // MARK: State
    
    private func applyFriendsState(userIds: [String]) {
        let shouldReload = displayedUserIds != userIds
        displayedUserIds = userIds
        emptyStateLabel.isHidden = !hasLoadedFriendsState || !userIds.isEmpty
        
        guard shouldReload else {
            refreshVisibleCells()
            return
        }
        
        UIView.performWithoutAnimation {
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
    }
    
    private func showInitialLoading() {
        emptyStateLabel.isHidden = true
        initialLoadingIndicator.startAnimating()
    }
    
    private func hideInitialLoading() {
        initialLoadingIndicator.stopAnimating()
    }
    
    private func configure(
        _ cell: SearchFriendItemCell,
        with item: Model.FriendsList.ViewModel.FriendCell
    ) {
        cell.title = item.username
        cell.baseColor = UIColor(hex: item.baseColor.hex, alpha: item.baseColor.a)
        cell.textColor = UIColor(hex: item.textColor.hex, alpha: item.textColor.a)
        cell.tintColor = UIColor(hex: item.tintColor.hex, alpha: item.tintColor.a)
        cell.avatarImage = item.avatarData.flatMap(UIImage.init(data:))
        cell.isAvatarLoading = item.isAvatarLoading
    }
    
    private func refreshVisibleCells() {
        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            guard displayedUserIds.indices.contains(indexPath.row),
                  let item = tableDataProvider.item(
                    for: displayedUserIds[indexPath.row]
                  ),
                  let cell = tableView.cellForRow(
                    at: indexPath
                  ) as? SearchFriendItemCell else {
                return
            }
            
            configure(cell, with: item)
        }
    }
}

// MARK: - Display logic

extension AddChatMemberController: AddChatMemberDisplayLogic {
    func displayStart(_ viewModel: Model.Start.ViewModel) {
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
        
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
        backButton.baseColor = elementsBaseColor
        backButton.tintColor = tintColor
        titleLabel.textColor = elementsBaseColor
        emptyStateLabel.textColor = textColor
        initialLoadingIndicator.color = textColor
    }
    
    func displayFriends(_ viewModel: Model.FriendsList.ViewModel) {
        hasLoadedFriendsState = true
        hideInitialLoading()
        applyFriendsState(userIds: viewModel.items.map { $0.id })
    }
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel) {
        guard let row = displayedUserIds.firstIndex(of: viewModel.userId) else {
            return
        }
        let indexPath = IndexPath(row: row, section: 0)
        guard let item = tableDataProvider.item(for: viewModel.userId),
              let cell = tableView.cellForRow(
                at: indexPath
              ) as? SearchFriendItemCell else {
            return
        }
        
        configure(cell, with: item)
    }
    
    func displayAddingState(_ viewModel: Model.AddingState.ViewModel) {
        tableView.isUserInteractionEnabled = !viewModel.isAdding
        UIView.animate(withDuration: 0.12) {
            self.tableView.alpha = viewModel.isAdding
                ? Constants.disabledTableAlpha
                : Constants.enabledTableAlpha
        }
    }
    
    func displayError(_ viewModel: Model.ShowError.ViewModel) {
        hideInitialLoading()
        
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

// MARK: - Table data source

extension AddChatMemberController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        displayedUserIds.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard displayedUserIds.indices.contains(indexPath.row),
              let item = tableDataProvider.item(
                for: displayedUserIds[indexPath.row]
              ) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchFriendItemCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let friendCell = cell as? SearchFriendItemCell else {
            return cell
        }
        
        configure(friendCell, with: item)
        return friendCell
    }
}

// MARK: - Table delegate

extension AddChatMemberController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard displayedUserIds.indices.contains(indexPath.row),
              let item = tableDataProvider.item(
                for: displayedUserIds[indexPath.row]
              ) else {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        interactor.addMember(userId: item.id)
    }
}
