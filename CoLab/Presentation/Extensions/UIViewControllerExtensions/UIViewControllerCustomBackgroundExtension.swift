//
//  UIViewControllerCustomBackgroundExtension.swift
//  CoLab
//
//  Created by User on 21.01.2026.
//

import UIKit

extension UIViewController {
    
    // Позволяет поставить на фон любую UIView
    func setCustomBackground(backgroundView: UIView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        // Растягиваем на весь экран
        NSLayoutConstraint.activate(
            [
                backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
}
