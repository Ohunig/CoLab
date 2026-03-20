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
        static let navigationTitle = "Chats"
        static let emptyStateText = "No chats yet"
        static let bottomInset: CGFloat = 120
        static let sideInset: CGFloat = 16
    }
    
    private let interactor: UserChatsBusinessLogic
    private let tableDataProvider: UserChatsTableDataLogic
    
    // TODO: позже добавить кастомный список/коллекцию под дизайн с макета
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateLabel = UILabel()
    private lazy var dataSource = makeDataSource()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncTableStateFromProvider()
        interactor.loadInitialChats()
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        navigationItem.title = Constants.navigationTitle
        
        emptyStateLabel.text = Constants.emptyStateText
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .lightGray
        emptyStateLabel.font = .systemFont(ofSize: 17, weight: .medium)
        emptyStateLabel.isHidden = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(ChatItemCell.self, forCellReuseIdentifier: ChatItemCell.reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: Constants.sideInset,
            bottom: 0,
            right: Constants.sideInset
        )
        tableView.contentInset.bottom = Constants.bottomInset
        tableView.verticalScrollIndicatorInsets.bottom = Constants.bottomInset
        tableView.tableFooterView = UIView()
        tableView.backgroundView = emptyStateLabel
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
}

// MARK: - Display logic

extension UserChatsController: UserChatsDisplayLogic {
    typealias Model = UserChatsModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Пока просто задаём фон. Позже сюда переедет сложный градиентный фон + хедер
        let bgColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        view.backgroundColor = bgColor
        tableView.backgroundColor = bgColor
    }
    
    func displayChats(_ viewModel: Model.ChatsList.ViewModel) {
        emptyStateLabel.isHidden = !viewModel.items.isEmpty
        
        let chatIds = viewModel.items.map { $0.id }
        guard view.window != nil else { return }
        
        applyChatsState(
            chatIds: chatIds,
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
    private func makeDataSource() -> UITableViewDiffableDataSource<Int, String> {
        UITableViewDiffableDataSource<Int, String>(tableView: tableView) { [weak self] tableView, indexPath, chatId in
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
    
    private func applySnapshot(chatIds: [String], animatingDifferences: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(chatIds, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func applyChatsState(
        chatIds: [String],
        updatedChatIds: [String],
        animatingDifferences: Bool
    ) {
        applySnapshot(chatIds: chatIds, animatingDifferences: animatingDifferences)
        
        guard updatedChatIds.isEmpty == false else { return }
        
        var snapshot = dataSource.snapshot()
        let reloadableChatIds = updatedChatIds.filter {
            snapshot.indexOfItem($0) != nil
        }
        
        guard reloadableChatIds.isEmpty == false else { return }
        
        snapshot.reloadItems(reloadableChatIds)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func syncTableStateFromProvider() {
        guard view.window != nil else { return }
        
        let chatIds = tableDataProvider.chatIds()
        emptyStateLabel.isHidden = !chatIds.isEmpty
        applyChatsState(
            chatIds: chatIds,
            updatedChatIds: chatIds,
            animatingDifferences: false
        )
    }
    
    private func configure(_ cell: ChatItemCell, with item: Model.ChatsList.ViewModel.ChatCell) {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        guard contentHeight > 0 else { return }
        
        if offsetY > contentHeight - height * 1.5 {
            interactor.loadNextPage()
        }
    }
}
