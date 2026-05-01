//
//  ContentSizedTableView.swift
//  CoLab
//
//  Created by User on 01.05.2026.
//

import Foundation
import UIKit

// Таблица подстраивающаяся под размеры содержимого
final class ContentSizedTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: contentSize.height
        )
    }
}
