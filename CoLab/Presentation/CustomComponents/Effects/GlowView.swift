//
//  GlowView.swift
//  CoLab
//
//  Created by User on 21.01.2026.
//

import UIKit

// Вью кругового градиента. Создаёт эффект свечения
final class GlowView: UIView {

    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let standardLocations: [CGFloat] = [0.0, 1.0]
        static let radiusMultiplier = 0.5
        static let startRadius: CGFloat = 0
    }

    var centerColor: UIColor = .clear {
        didSet { setNeedsDisplay() }
    }

    var outerColor: UIColor = .clear {
        didSet { setNeedsDisplay() }
    }
    
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentMode = .redraw
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    // MARK: Override draw

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()
        defer { ctx.restoreGState() }

        let colors = [centerColor.cgColor, outerColor.cgColor] as CFArray

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors,
            locations: Constants.standardLocations
        ) else { return }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = rect.width * Constants.radiusMultiplier

        ctx.drawRadialGradient(
            gradient,
            startCenter: center,
            startRadius: Constants.startRadius,
            endCenter: center,
            endRadius: r,
            options: [.drawsAfterEndLocation]
        )
    }
}
