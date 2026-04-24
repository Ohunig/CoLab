//
//  MessageBubbleView.swift
//  CoLab
//
//  Created by User on 25.03.2026.
//

import UIKit

final class MessageBubbleView: UIView {
    
    enum Direction: Equatable {
        case incoming
        case outgoing
    }
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let topInset: CGFloat = 16
        static let bottomInset: CGFloat = 16
        static let horizontalInset: CGFloat = 22
        static let senderToTextSpacing: CGFloat = 6
        
        static let standardCornerRadius: CGFloat = 26
        static let compactBottomCornerRadius: CGFloat = 10
        static let standardBorderWidth: CGFloat = 1.5
        
        static let senderRowWidth: CGFloat = 128
        static let senderFontSize: CGFloat = 13
        static let textFontSize: CGFloat = 18
        
        static let gradientStartX: CGFloat = 0
        static let gradientEndX: CGFloat = 1
        static let gradientY: CGFloat = 0.5
    }
    
    private let gradientLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    
    private let senderNameLabel = UILabel()
    private let textLabel = UILabel()
    
    private lazy var senderHeightConstraint = senderNameLabel.heightAnchor.constraint(
        equalToConstant: ceil(senderFont.lineHeight)
    )
    private lazy var senderWidthConstraint = senderNameLabel.widthAnchor.constraint(
        equalToConstant: Constants.senderRowWidth
    )
    private lazy var textTopWithSenderConstraint = textLabel.topAnchor.constraint(
        equalTo: senderNameLabel.bottomAnchor,
        constant: Constants.senderToTextSpacing
    )
    private lazy var textTopWithoutSenderConstraint = textLabel.topAnchor.constraint(
        equalTo: topAnchor,
        constant: Constants.topInset
    )
    
    private let senderFont = UIFont.systemFont(
        ofSize: Constants.senderFontSize,
        weight: .medium
    )
    private let messageFont = UIFont.systemFont(
        ofSize: Constants.textFontSize,
        weight: .regular
    )
    
    private var showsSenderRow = false
    
    // MARK: Properties
    
    var direction: Direction = .incoming {
        didSet {
            setNeedsLayout()
        }
    }
    
    var text: String = "" {
        didSet {
            textLabel.text = text
            invalidateIntrinsicContentSize()
        }
    }
    
    var senderName: String? {
        didSet {
            updateSenderNameState()
            invalidateIntrinsicContentSize()
        }
    }
    
    var reservesSenderNameSpace = false {
        didSet {
            updateSenderNameState()
            invalidateIntrinsicContentSize()
        }
    }
    
    // Colors
    
    var fillColor: UIColor? {
        didSet {
            updateAppearance()
        }
    }
    
    var textColor: UIColor? {
        didSet {
            textLabel.textColor = textColor
        }
    }
    
    var senderTextColor: UIColor? {
        didSet {
            senderNameLabel.textColor = senderTextColor
        }
    }
    
    var borderColor: UIColor? {
        didSet {
            updateAppearance()
        }
    }
    
    var gradientStartColor: UIColor? {
        didSet {
            updateAppearance()
        }
    }
    
    var gradientEndColor: UIColor? {
        didSet {
            updateAppearance()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        // Для bubble нам нужна только "естественная" ширина.
        // Высоту снаружи задаёт ячейка по своему расчёту.
        let textSize = textLabel.sizeThatFits(
            CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        let senderWidth = showsSenderRow ? Constants.senderRowWidth : 0
        let contentWidth = max(ceil(textSize.width), senderWidth)
        
        return CGSize(
            width: contentWidth + Constants.horizontalInset * 2,
            height: UIView.noIntrinsicMetric
        )
    }
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    // MARK: Preferred height
    
    static func preferredHeight(
        for text: String,
        senderName: String?,
        maxWidth: CGFloat,
        reservesSenderNameSpace: Bool
    ) -> CGFloat {
        let labelMaxWidth = max(0, maxWidth - Constants.horizontalInset * 2)
        let messageBoundingRect = NSString(string: text).boundingRect(
            with: CGSize(width: labelMaxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [
                .font: UIFont.systemFont(
                    ofSize: Constants.textFontSize,
                    weight: .regular
                )
            ],
            context: nil
        )
        
        let showsSenderRow = reservesSenderNameSpace || (senderName?.isEmpty == false)
        let senderHeight = showsSenderRow
            ? ceil(
                UIFont.systemFont(
                    ofSize: Constants.senderFontSize,
                    weight: .medium
                ).lineHeight
            ) + Constants.senderToTextSpacing
            : 0
        
        return Constants.topInset
            + senderHeight
            + ceil(messageBoundingRect.height)
            + Constants.bottomInset
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        configureLayers()
        configureSenderNameLabel()
        configureTextLabel()
        configureLayout()
        
        updateAppearance()
        updateSenderNameState()
    }
    
    private func configureLayers() {
        layer.insertSublayer(gradientLayer, at: 0)
        layer.addSublayer(borderLayer)
        layer.mask = maskLayer
        
        gradientLayer.startPoint = CGPoint(
            x: Constants.gradientStartX,
            y: Constants.gradientY
        )
        gradientLayer.endPoint = CGPoint(
            x: Constants.gradientEndX,
            y: Constants.gradientY
        )
        
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = Constants.standardBorderWidth
    }
    
    private func configureSenderNameLabel() {
        senderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        senderNameLabel.font = senderFont
        senderNameLabel.numberOfLines = 1
        senderNameLabel.lineBreakMode = .byTruncatingTail
        addSubview(senderNameLabel)
    }
    
    private func configureTextLabel() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = messageFont
        textLabel.numberOfLines = 0
        addSubview(textLabel)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            senderNameLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Constants.topInset
            ),
            senderNameLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.horizontalInset
            ),
            senderWidthConstraint,
            senderHeightConstraint,
            
            textLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.horizontalInset
            ),
            textLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.horizontalInset
            ),
            textLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Constants.bottomInset
            )
        ])
    }
    
    // MARK: Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
        let path = bubblePath(in: bounds)
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        
        borderLayer.frame = bounds
        borderLayer.path = path.cgPath
    }
    
    // MARK: Update state
    
    private func updateAppearance() {
        let hasGradient = gradientStartColor != nil && gradientEndColor != nil
        
        if hasGradient {
            backgroundColor = .clear
            gradientLayer.isHidden = false
            gradientLayer.colors = [
                gradientStartColor?.cgColor ?? UIColor.clear.cgColor,
                gradientEndColor?.cgColor ?? UIColor.clear.cgColor
            ]
        } else {
            backgroundColor = fillColor
            gradientLayer.isHidden = true
            gradientLayer.colors = nil
        }
        
        borderLayer.strokeColor = borderColor?.cgColor
        borderLayer.isHidden = borderColor == nil
    }
    
    private func updateSenderNameState() {
        let hasSenderName = senderName?.isEmpty == false
        let shouldShowSenderRow = reservesSenderNameSpace || hasSenderName
        
        showsSenderRow = shouldShowSenderRow
        senderNameLabel.text = hasSenderName ? senderName : nil
        senderNameLabel.alpha = hasSenderName ? 1 : 0
        senderNameLabel.isHidden = !shouldShowSenderRow
        
        if shouldShowSenderRow {
            textTopWithoutSenderConstraint.isActive = false
            textTopWithSenderConstraint.isActive = true
        } else {
            textTopWithSenderConstraint.isActive = false
            textTopWithoutSenderConstraint.isActive = true
        }
    }
    
    // MARK: Bubble path
    
    // Нижний угол с стороны "хвоста" делаем менее округлым.
    // Так bubble выглядит ближе к референсу чата.
    private func bubblePath(in rect: CGRect) -> UIBezierPath {
        guard rect.width > 0, rect.height > 0 else {
            return UIBezierPath(rect: rect)
        }
        
        let minSide = min(rect.width, rect.height)
        let standardRadius = min(Constants.standardCornerRadius, minSide / 2)
        let compactRadius = min(Constants.compactBottomCornerRadius, minSide / 2)
        
        let topLeft = standardRadius
        let topRight = standardRadius
        let bottomLeft = direction == .incoming ? compactRadius : standardRadius
        let bottomRight = direction == .outgoing ? compactRadius : standardRadius
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: topLeft, y: 0))
        path.addLine(to: CGPoint(x: rect.width - topRight, y: 0))
        path.addArc(
            withCenter: CGPoint(x: rect.width - topRight, y: topRight),
            radius: topRight,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - bottomRight))
        path.addArc(
            withCenter: CGPoint(x: rect.width - bottomRight, y: rect.height - bottomRight),
            radius: bottomRight,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: bottomLeft, y: rect.height))
        path.addArc(
            withCenter: CGPoint(x: bottomLeft, y: rect.height - bottomLeft),
            radius: bottomLeft,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: 0, y: topLeft))
        path.addArc(
            withCenter: CGPoint(x: topLeft, y: topLeft),
            radius: topLeft,
            startAngle: .pi,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        path.close()
        return path
    }
}
