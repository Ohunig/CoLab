//
//  ChatMessagesListView.swift
//  CoLab
//
//  Created by User on 26.03.2026.
//

import UIKit

final class ChatMessagesListView: UIView {
    
    private struct Constants {
        static let messagesHorizontalInset: CGFloat = 22
        static let latestMessageBottomInset: CGFloat = 10
        static let topMessagesInset: CGFloat = 8
        static let incomingBubbleAlpha: CGFloat = 0.5
        
        static let paginationThreshold: CGFloat = 120
        static let autoScrollThreshold: CGFloat = 80
        
        static let emptyStateText = "No messages yet"
        static let emptyStateFontSize: CGFloat = 17
        
        static let invertedTransform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    private typealias Section = Int
    private typealias ItemIdentifier = String
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, ItemIdentifier>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemIdentifier>
    
    private enum MessagesChangeKind {
        case initial
        case prepend
        case append
        case update
    }
    
    private struct LeadingEdgePosition {
        let contentOffsetY: CGFloat
        let contentHeight: CGFloat
    }
    
    private let collectionDataProvider: ChatMessagesCollectionDataLogic
    
    // Область сообщений сама знает когда нужно попросить следующую страницу.
    var onNeedsPreviousMessages: (() -> Void)?
    
    private var isPreviousPagePaginationArmed = true
    private var isShowingInitialLoading = false
    private var isAdjustingForKeyboard = false
    private var shouldForceLatestOnNextAppend = false
    private var coveredBottomHeight: CGFloat = 0
    
    private let messagesContentView = UIView()
    private let emptyStateLabel = UILabel()
    private let initialLoadingOverlay = LoadingOverlay()
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    )
    private lazy var dataSource = makeDataSource()
    
    // MARK: Lifecycle
    
    init(collectionDataProvider: ChatMessagesCollectionDataLogic) {
        self.collectionDataProvider = collectionDataProvider
        super.init(frame: .zero)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionInsets()
    }
    
    // MARK: State
    
    var hasMessages: Bool {
        !collectionDataProvider.messageIds().isEmpty
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        backgroundColor = .clear
        
        messagesContentView.translatesAutoresizingMaskIntoConstraints = false
        messagesContentView.backgroundColor = .clear
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = Constants.emptyStateText
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = .systemFont(
            ofSize: Constants.emptyStateFontSize,
            weight: .medium
        )
        emptyStateLabel.textColor = .white
        emptyStateLabel.isHidden = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.transform = Constants.invertedTransform
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(
            MessageCell.self,
            forCellWithReuseIdentifier: MessageCell.reuseIdentifier
        )
        
        addSubview(messagesContentView)
        messagesContentView.addSubview(collectionView)
        messagesContentView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            messagesContentView.topAnchor.constraint(equalTo: topAnchor),
            messagesContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            messagesContentView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.messagesHorizontalInset
            ),
            messagesContentView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.messagesHorizontalInset
            ),
            
            collectionView.topAnchor.constraint(equalTo: messagesContentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: messagesContentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: messagesContentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: messagesContentView.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: messagesContentView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: messagesContentView.centerYAnchor)
        ])
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }
    
    // MARK: Data source
    
    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, messageId in
            guard let self,
                  let item = self.collectionDataProvider.item(for: messageId) else {
                return UICollectionViewCell()
            }
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MessageCell.reuseIdentifier,
                for: indexPath
            )
            
            guard let messageCell = cell as? MessageCell else {
                return cell
            }
            
            self.configure(messageCell, with: item)
            return messageCell
        }
    }
    
    // MARK: Public methods
    
    func updateViewportInsets(coveredBottomHeight: CGFloat) {
        self.coveredBottomHeight = coveredBottomHeight
        updateCollectionInsets()
    }
    
    func beginKeyboardTransition() {
        isAdjustingForKeyboard = true
    }
    
    func endKeyboardTransition() {
        isAdjustingForKeyboard = false
    }
    
    func forceLatestOnNextAppend() {
        shouldForceLatestOnNextAppend = true
    }
    
    func scrollToLatest(animated: Bool) {
        collectionView.setContentOffset(
            CGPoint(x: 0, y: -collectionView.adjustedContentInset.top),
            animated: animated
        )
    }
    
    func showInitialLoadingIfNeeded() {
        guard !isShowingInitialLoading else { return }
        isShowingInitialLoading = true
        emptyStateLabel.isHidden = true
        initialLoadingOverlay.isUserInteractionEnabled = false
        initialLoadingOverlay.show(over: self)
    }
    
    func hideInitialLoading() {
        guard isShowingInitialLoading else { return }
        isShowingInitialLoading = false
        initialLoadingOverlay.hide()
    }
    
    // Если сообщения уже пришли пока экран ещё не был показан,
    // синхронизируем коллекцию из состояния presenter при первом появлении.
    func syncStateFromProviderIfNeeded() {
        let messageIds = collectionDataProvider.messageIds()
        if messageIds.isEmpty {
            emptyStateLabel.isHidden = isShowingInitialLoading
        } else {
            hideInitialLoading()
            emptyStateLabel.isHidden = true
        }
        
        guard !messageIds.isEmpty else { return }
        guard dataSource.snapshot().itemIdentifiers != displayedMessageIds(from: messageIds) else {
            return
        }
        
        applyInitialMessages(messageIds: messageIds, updatedMessageIds: [])
    }
    
    func displayMessages(_ viewModel: ChatMessagesModels.MessagesList.ViewModel) {
        hideInitialLoading()
        emptyStateLabel.isHidden = !viewModel.items.isEmpty
        
        guard window != nil else { return }
        
        let messageIds = viewModel.items.map(\.id)
        let displayedIds = displayedMessageIds(from: messageIds)
        
        switch changeKind(
            for: displayedIds,
            updatedMessageIds: viewModel.updatedMessageIds
        ) {
        case .initial:
            applyInitialMessages(
                messageIds: messageIds,
                updatedMessageIds: viewModel.updatedMessageIds
            )
        case .prepend:
            applyOlderMessages(
                messageIds: messageIds,
                updatedMessageIds: viewModel.updatedMessageIds
            )
        case .append:
            applyNewerMessages(
                messageIds: messageIds,
                updatedMessageIds: viewModel.updatedMessageIds
            )
        case .update:
            applyUpdatedMessages(updatedMessageIds: viewModel.updatedMessageIds)
        case nil:
            break
        }
    }
    
    // MARK: Snapshot
    
    // Presenter хранит сообщения в порядке old -> new.
    // Для перевёрнутой коллекции подаём их наоборот: new -> old.
    private func displayedMessageIds(from messageIds: [String]) -> [String] {
        Array(messageIds.reversed())
    }
    
    private func makeSnapshot(
        messageIds: [String],
        reconfiguredMessageIds: [String] = []
    ) -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(displayedMessageIds(from: messageIds), toSection: 0)
        
        let reconfigurableIds = reconfiguredMessageIds.filter {
            snapshot.indexOfItem($0) != nil
        }
        if !reconfigurableIds.isEmpty {
            snapshot.reconfigureItems(reconfigurableIds)
        }
        
        return snapshot
    }
    
    private func changeKind(
        for displayedMessageIds: [String],
        updatedMessageIds: [String]
    ) -> MessagesChangeKind? {
        let currentDisplayedIds = dataSource.snapshot().itemIdentifiers
        
        guard !displayedMessageIds.isEmpty else { return nil }
        
        if currentDisplayedIds.isEmpty {
            return .initial
        }
        
        if currentDisplayedIds == displayedMessageIds {
            return updatedMessageIds.isEmpty ? nil : .update
        }
        
        if displayedMessageIds.count >= currentDisplayedIds.count {
            let currentCount = currentDisplayedIds.count
            
            if Array(displayedMessageIds.prefix(currentCount)) == currentDisplayedIds {
                return .prepend
            }
            
            if Array(displayedMessageIds.suffix(currentCount)) == currentDisplayedIds {
                return .append
            }
        }
        
        return .initial
    }
    
    // MARK: Configure cells
    
    private func configure(
        _ cell: MessageCell,
        with item: ChatMessagesModels.MessagesList.ViewModel.MessageItem
    ) {
        let animateContentChanges = cell.beginRendering(messageId: item.id)
        
        cell.direction = item.direction == .outgoing ? .outgoing : .incoming
        cell.text = item.text
        cell.setSenderName(item.senderName, animated: animateContentChanges)
        cell.setAvatarData(item.avatarData, animated: animateContentChanges)
        
        let bubbleBaseColor = UIColor(
            hex: item.baseColor.hex,
            alpha: item.baseColor.a
        )
        
        cell.bubbleColor = item.direction == .incoming
            ? bubbleBaseColor.withAlphaComponent(Constants.incomingBubbleAlpha)
            : bubbleBaseColor
        cell.bubbleBorderColor = item.borderColor.map {
            UIColor(hex: $0.hex, alpha: $0.a)
        }
        cell.bubbleGradientStartColor = item.gradientStartColor.map {
            UIColor(hex: $0.hex, alpha: $0.a)
        }
        cell.bubbleGradientEndColor = item.gradientEndColor.map {
            UIColor(hex: $0.hex, alpha: $0.a)
        }
        cell.messageTextColor = UIColor(
            hex: item.textColor.hex,
            alpha: item.textColor.a
        )
        cell.senderTextColor = item.senderTextColor.map {
            UIColor(hex: $0.hex, alpha: $0.a)
        }
    }
    
    // MARK: Apply messages
    
    private func applyInitialMessages(
        messageIds: [String],
        updatedMessageIds: [String]
    ) {
        dataSource.apply(
            makeSnapshot(
                messageIds: messageIds,
                reconfiguredMessageIds: updatedMessageIds
            ),
            animatingDifferences: false
        ) { [weak self] in
            guard let self else { return }
            self.collectionView.layoutIfNeeded()
            self.scrollToLatest(animated: false)
        }
    }
    
    // В inverted collection старая страница добавляется в дальний край.
    // Поэтому position пользователя можно не восстанавливать вручную.
    private func applyOlderMessages(
        messageIds: [String],
        updatedMessageIds: [String]
    ) {
        dataSource.apply(
            makeSnapshot(
                messageIds: messageIds,
                reconfiguredMessageIds: updatedMessageIds
            ),
            animatingDifferences: false
        )
    }
    
    private func applyNewerMessages(
        messageIds: [String],
        updatedMessageIds: [String]
    ) {
        let shouldStickToLatest = shouldForceLatestOnNextAppend || isNearLatest()
        let leadingEdgePosition = shouldStickToLatest ? nil : makeLeadingEdgePosition()
        
        dataSource.apply(
            makeSnapshot(
                messageIds: messageIds,
                reconfiguredMessageIds: updatedMessageIds
            ),
            animatingDifferences: true
        ) { [weak self] in
            guard let self else { return }
            self.collectionView.layoutIfNeeded()
            
            if shouldStickToLatest {
                self.shouldForceLatestOnNextAppend = false
                self.scrollToLatest(animated: true)
            } else if let leadingEdgePosition {
                self.restoreLeadingEdgePosition(leadingEdgePosition)
            }
        }
    }
    
    private func applyUpdatedMessages(updatedMessageIds: [String]) {
        guard !updatedMessageIds.isEmpty else { return }
        
        var snapshot = dataSource.snapshot()
        let reconfigurableIds = updatedMessageIds.filter {
            snapshot.indexOfItem($0) != nil
        }
        guard !reconfigurableIds.isEmpty else { return }
        
        snapshot.reconfigureItems(reconfigurableIds)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: Scroll state
    
    private func makeLeadingEdgePosition() -> LeadingEdgePosition {
        LeadingEdgePosition(
            contentOffsetY: collectionView.contentOffset.y,
            contentHeight: collectionView.collectionViewLayout.collectionViewContentSize.height
        )
    }
    
    private func restoreLeadingEdgePosition(_ position: LeadingEdgePosition) {
        let newContentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let deltaHeight = newContentHeight - position.contentHeight
        let minOffsetY = -collectionView.adjustedContentInset.top
        
        collectionView.contentOffset.y = max(
            minOffsetY,
            position.contentOffsetY + deltaHeight
        )
    }
    
    private func isNearLatest() -> Bool {
        collectionView.contentOffset.y <=
            -collectionView.adjustedContentInset.top + Constants.autoScrollThreshold
    }
    
    private func isNearOldestMessagesEdge(_ scrollView: UIScrollView) -> Bool {
        let visibleBottomY = scrollView.contentOffset.y
            + scrollView.bounds.height
            - scrollView.adjustedContentInset.bottom
        let contentBottomY = scrollView.collectionViewLayoutContentHeight
        
        return contentBottomY - visibleBottomY <= Constants.paginationThreshold
    }
    
    // MARK: Layout state
    
    private func updateCollectionInsets() {
        let topInset = coveredBottomHeight + Constants.latestMessageBottomInset
        let bottomInset = Constants.topMessagesInset
        let previousInset = collectionView.contentInset
        let shouldStickToLatest = isAdjustingForKeyboard || isNearLatest()
        
        guard abs(previousInset.top - topInset) > 0.5
                || abs(previousInset.bottom - bottomInset) > 0.5 else {
            return
        }
        
        collectionView.contentInset = UIEdgeInsets(
            top: topInset,
            left: 0,
            bottom: bottomInset,
            right: 0
        )
        
        if shouldStickToLatest, hasMessages {
            scrollToLatest(animated: false)
        }
    }
}

// MARK: - Collection delegate

extension ChatMessagesListView: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize.height > 0 else { return }
        
        if !isNearOldestMessagesEdge(scrollView) {
            isPreviousPagePaginationArmed = true
            return
        }
        
        guard isPreviousPagePaginationArmed else { return }
        isPreviousPagePaginationArmed = false
        onNeedsPreviousMessages?()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let messageId = dataSource.itemIdentifier(for: indexPath),
              let item = collectionDataProvider.item(for: messageId) else {
            return CGSize(width: collectionView.bounds.width, height: 1)
        }
        
        let height = MessageCell.preferredHeight(
            for: item.text,
            senderName: item.senderName,
            direction: item.direction == .outgoing ? .outgoing : .incoming,
            width: collectionView.bounds.width
        )
        
        return CGSize(width: collectionView.bounds.width, height: height)
    }
}

// MARK: - UIScrollView helper

private extension UIScrollView {
    var collectionViewLayoutContentHeight: CGFloat {
        guard let collectionView = self as? UICollectionView else {
            return contentSize.height
        }
        return collectionView.collectionViewLayout.collectionViewContentSize.height
    }
}
