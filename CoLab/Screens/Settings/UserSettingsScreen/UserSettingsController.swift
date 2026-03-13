//
//  UserSettingsController.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation
import UIKit

final class UserSettingsController: UIViewController {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
    }
    
    private let interactor: UserSettingsBusinessLogic
    
    private let backgroundView = MainBackgroundView()
    
    // MARK: Lifecycle
    
    init(interactor: UserSettingsBusinessLogic) {
        self.interactor = interactor
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
    
    // MARK: Configure UI
    
    private func configureUI() {
        setCustomBackground(backgroundView: backgroundView)
        
    }
}

// MARK: - Display logic extension

extension UserSettingsController: UserSettingsDisplayLogic {
    
    func displayStart(_ viewModel: Model.Start.ViewModel) {
        // Получаем нужные цвета в виде UIColor
        let bgColor = UIColor(hex: viewModel.bg.hex, alpha: viewModel.bg.a)
        let bgGradientColor = UIColor(hex: viewModel.bgGradient.hex, alpha: viewModel.bgGradient.a)
        let elementsBaseColor = UIColor(hex: viewModel.elementsBase.hex, alpha: viewModel.elementsBase.a)
        let tintColor = UIColor(hex: viewModel.tint.hex, alpha: viewModel.tint.a)
        let textColor = UIColor(hex: viewModel.textColor.hex, alpha: viewModel.textColor.a)
        
        // Фон
        backgroundView.bgColor = bgColor
        backgroundView.gradientColor = bgGradientColor
    }
}
