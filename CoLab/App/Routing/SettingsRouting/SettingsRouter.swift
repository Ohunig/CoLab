//
//  SettingsRouter.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation
import UIKit

// Навигация между экранами настроек
final class SettingsRouter: SettingsRoutingLogic {
    
    private weak var navController: UINavigationController?
    
    var navigationController: UINavigationController? {
        get { navController }
        set { navController = newValue }
    }
}
