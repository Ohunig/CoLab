//
//  ModalTopSafeAreaCompensating.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import Foundation

// Позволяет экранам внутри модальной ветки компенсировать верхний safe area
protocol ModalTopSafeAreaCompensating: AnyObject {
    func setModalTopSafeAreaCompensation(_ value: CGFloat)
}
