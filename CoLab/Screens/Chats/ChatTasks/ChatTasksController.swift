//
//  ChatTasksController.swift
//  CoLab
//
//  Created by User on 10.05.2026.
//

import UIKit

final class ChatTasksController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let horizontalInset: CGFloat = 22
        static let backToUnsafe: CGFloat = 30
        static let topInset: CGFloat = 40
        static let bottomInset: CGFloat = 24
        
        static let activeTitleText = "Активные задачи"
        static let completedTitleText = "Выполненные задачи"
        static let createButtonText = "Создать задачу"
        
        static let sectionFontSize: CGFloat = 22
        static let sectionToTableTop: CGFloat = 10
        static let createButtonTop: CGFloat = 12
        static let completedTop: CGFloat = 32
        static let createButtonHeight: CGFloat = 80
        static let estimatedRowHeight: CGFloat = 88
    }
    
    private enum TableKind {
        case active
        case completed
    }
    
    private typealias Section = Int
    private typealias ItemIdentifier = String
    private typealias DataSource = UITableViewDiffableDataSource<Section, ItemIdentifier>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemIdentifier>
    
    private let interactor: ChatTasksBusinessLogic
    private let tableDataProvider: ChatTasksTableDataLogic
    
    private let backgroundView = MainBackgroundView()
    private let scrollView = UIScrollView()
    private let backButton = BackNavBarButton()
    private let activeTitleLabel = UILabel()
    private let completedTitleLabel = UILabel()
    private let activeTableView = ContentSizedTableView(frame: .zero, style: .plain)
    private let completedTableView = ContentSizedTableView(frame: .zero, style: .plain)
    private let createButton = ItemCell()
    
    private lazy var activeDataSource = makeDataSource(
        tableView: activeTableView,
        tableKind: .active
    )
    private lazy var completedDataSource = makeDataSource(
        tableView: completedTableView,
        tableKind: .completed
    )
    
    private var bgUIColor = UIColor.clear
    private var bgGradientUIColor = UIColor.clear
    private var baseUIColor = UIColor.white
    private var textUIColor = UIColor.white
    private var firstGradientUIColor = UIColor.white
    private var secondGradientUIColor = UIColor.white
    private var activeTitleTopConstraint: NSLayoutConstraint?
    private var createButtonTopToActiveTableConstraint: NSLayoutConstraint?
    private var bottomToCompletedTableConstraint: NSLayoutConstraint?
    private var bottomToCompletedTitleConstraint: NSLayoutConstraint?
    
    // MARK: Lifecycle
    
    init(
        interactor: ChatTasksBusinessLogic,
        tableDataProvider: ChatTasksTableDataLogic
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
        interactor.startTasksUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        interactor.stopTasksUpdates()
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
        configureSections()
        configureTables()
        configureCreateButton()
        configureLayout()
        updateInsetConstraints()
    }
    
    private func configureScrollView() {
        scrollView.delaysContentTouches = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
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
                self?.navigationController?.popViewController(animated: true)
            },
            for: .touchUpInside
        )
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.horizontalInset
            ),
            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: -Constants.backToUnsafe
            )
        ])
    }
    
    private func configureSections() {
        configureSectionLabel(activeTitleLabel, text: Constants.activeTitleText)
        configureSectionLabel(completedTitleLabel, text: Constants.completedTitleText)
        
        [activeTitleLabel, completedTitleLabel].forEach {
            scrollView.addSubview($0)
        }
        
    }
    
    private func configureSectionLabel(_ label: UILabel, text: String) {
        label.text = text
        label.font = .systemFont(
            ofSize: Constants.sectionFontSize,
            weight: .medium
        )
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureTables() {
        [activeTableView, completedTableView].forEach { tableView in
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
            tableView.register(
                TaskItemCell.self,
                forCellReuseIdentifier: TaskItemCell.reuseIdentifier
            )
            tableView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(tableView)
        }
        
        NSLayoutConstraint.activate([
            activeTableView.topAnchor.constraint(
                equalTo: activeTitleLabel.bottomAnchor,
                constant: Constants.sectionToTableTop
            ),
            activeTableView.leadingAnchor.constraint(equalTo: activeTitleLabel.leadingAnchor),
            activeTableView.trailingAnchor.constraint(equalTo: activeTitleLabel.trailingAnchor),
            
            completedTableView.topAnchor.constraint(
                equalTo: completedTitleLabel.bottomAnchor,
                constant: Constants.sectionToTableTop
            ),
            completedTableView.leadingAnchor.constraint(equalTo: activeTitleLabel.leadingAnchor),
            completedTableView.trailingAnchor.constraint(equalTo: activeTitleLabel.trailingAnchor)
        ])
    }
    
    private func configureCreateButton() {
        createButton.text = Constants.createButtonText
        createButton.addAction(
            UIAction { [weak self] _ in
                self?.showCreateTaskSheet()
            },
            for: .touchUpInside
        )
        createButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(createButton)
        
        createButtonTopToActiveTableConstraint = createButton.topAnchor.constraint(
            equalTo: activeTableView.bottomAnchor,
            constant: Constants.createButtonTop
        )
        createButtonTopToActiveTableConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            createButton.leadingAnchor.constraint(equalTo: activeTitleLabel.leadingAnchor),
            createButton.trailingAnchor.constraint(equalTo: activeTitleLabel.trailingAnchor),
            createButton.heightAnchor.constraint(
                equalToConstant: Constants.createButtonHeight
            )
        ])
    }
    
    private func configureLayout() {
        activeTitleTopConstraint = activeTitleLabel.topAnchor.constraint(
            equalTo: scrollView.contentLayoutGuide.topAnchor
        )
        activeTitleTopConstraint?.isActive = true
        bottomToCompletedTableConstraint = completedTableView.bottomAnchor.constraint(
            equalTo: scrollView.contentLayoutGuide.bottomAnchor
        )
        bottomToCompletedTitleConstraint = completedTitleLabel.bottomAnchor.constraint(
            equalTo: scrollView.contentLayoutGuide.bottomAnchor
        )
        bottomToCompletedTableConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            activeTitleLabel.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: Constants.horizontalInset
            ),
            activeTitleLabel.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -Constants.horizontalInset
            ),
            
            completedTitleLabel.topAnchor.constraint(
                equalTo: createButton.bottomAnchor,
                constant: Constants.completedTop
            ),
            completedTitleLabel.leadingAnchor.constraint(equalTo: activeTitleLabel.leadingAnchor),
            completedTitleLabel.trailingAnchor.constraint(equalTo: activeTitleLabel.trailingAnchor)
        ])
    }
    
    // MARK: Factory methods
    
    private func makeDataSource(
        tableView: UITableView,
        tableKind: TableKind
    ) -> DataSource {
        DataSource(tableView: tableView) { [weak self] tableView, indexPath, taskId in
            guard let self,
                  let item = self.tableDataProvider.item(for: taskId) else {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TaskItemCell.reuseIdentifier,
                for: indexPath
            )
            
            guard let taskCell = cell as? TaskItemCell else {
                return cell
            }
            
            self.configure(taskCell, with: item)
            return taskCell
        }
    }
    
    private func makeSnapshot(
        taskIds: [String],
        reloadingExistingItemsIn dataSource: DataSource
    ) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(taskIds, toSection: 0)
        
        let currentTaskIds = Set(dataSource.snapshot().itemIdentifiers)
        let reloadTaskIds = taskIds.filter { currentTaskIds.contains($0) }
        snapshot.reloadItems(reloadTaskIds)
        
        return snapshot
    }
    
    private func configure(
        _ cell: TaskItemCell,
        with item: Model.TasksList.ViewModel.TaskCell
    ) {
        cell.title = item.text
        cell.isCompletedTask = item.isCompleted
        cell.isVoteButtonEnabled = item.isVoteButtonEnabled
        cell.onVoteTap = { [weak self] in
            self?.interactor.sendTaskToVote(taskId: item.id)
        }
        cell.baseColor = UIColor(
            hex: item.baseColor.hex,
            alpha: item.baseColor.a
        )
        cell.textColor = UIColor(
            hex: item.textColor.hex,
            alpha: item.textColor.a
        )
    }
    
    // MARK: State
    
    private func applyTasksState(
        activeTaskIds: [String],
        completedTaskIds: [String]
    ) {
        activeTableView.isHidden = activeTaskIds.isEmpty
        completedTableView.isHidden = completedTaskIds.isEmpty
        
        bottomToCompletedTableConstraint?.isActive = !completedTaskIds.isEmpty
        bottomToCompletedTitleConstraint?.isActive = completedTaskIds.isEmpty
        
        activeDataSource.apply(
            makeSnapshot(
                taskIds: activeTaskIds,
                reloadingExistingItemsIn: activeDataSource
            ),
            animatingDifferences: false
        ) { [weak self] in
            self?.activeTableView.invalidateIntrinsicContentSize()
        }
        
        completedDataSource.apply(
            makeSnapshot(
                taskIds: completedTaskIds,
                reloadingExistingItemsIn: completedDataSource
            ),
            animatingDifferences: false
        ) { [weak self] in
            self?.completedTableView.invalidateIntrinsicContentSize()
        }
    }
    
    private func updateInsetConstraints() {
        activeTitleTopConstraint?.constant = view.safeAreaInsets.top + Constants.topInset
        let bottomInset = -(view.safeAreaInsets.bottom + Constants.bottomInset)
        bottomToCompletedTableConstraint?.constant = bottomInset
        bottomToCompletedTitleConstraint?.constant = bottomInset
    }
    
    // MARK: Actions
    
    private func showCreateTaskSheet() {
        let controller = CreateTaskController(
            bgColor: bgUIColor,
            bgGradientColor: bgGradientUIColor,
            baseColor: baseUIColor,
            textColor: textUIColor,
            firstGradientColor: firstGradientUIColor,
            secondGradientColor: secondGradientUIColor,
            onAdd: { [weak self] text in
                self?.interactor.createTask(text: text)
            }
        )
        controller.modalPresentationStyle = .pageSheet
        
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(controller, animated: true)
    }
}

// MARK: - Display logic

extension ChatTasksController: ChatTasksDisplayLogic {
    typealias Model = ChatTasksModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        bgUIColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        bgGradientUIColor = UIColor(
            hex: viewModel.bgGradient.hex,
            alpha: viewModel.bgGradient.a
        )
        firstGradientUIColor = UIColor(
            hex: viewModel.firstGradient.hex,
            alpha: viewModel.firstGradient.a
        )
        secondGradientUIColor = UIColor(
            hex: viewModel.secondGradient.hex,
            alpha: viewModel.secondGradient.a
        )
        baseUIColor = UIColor(
            hex: viewModel.elementsBase.hex,
            alpha: viewModel.elementsBase.a
        )
        textUIColor = UIColor(
            hex: viewModel.textColor.hex,
            alpha: viewModel.textColor.a
        )
        let tintColor = UIColor(hex: viewModel.tint.hex, alpha: viewModel.tint.a)
        
        backgroundView.bgColor = bgUIColor
        backgroundView.gradientColor = bgGradientUIColor
        backButton.baseColor = baseUIColor
        backButton.tintColor = tintColor
        
        activeTitleLabel.textColor = tintColor
        completedTitleLabel.textColor = tintColor
        
        createButton.baseColor = baseUIColor
        createButton.textColor = textUIColor
        createButton.tintColor = tintColor
    }
    
    func displayTasks(_ viewModel: Model.TasksList.ViewModel) {
        applyTasksState(
            activeTaskIds: viewModel.activeItems.map(\.id),
            completedTaskIds: viewModel.completedItems.map(\.id)
        )
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

// MARK: - UITableViewDelegate

extension ChatTasksController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        shouldHighlightRowAt indexPath: IndexPath
    ) -> Bool {
        false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
