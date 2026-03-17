//
//  SettingsRoutingLogic.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import Foundation
import UIKit

// Логика навигации между экранами настроек
protocol SettingsRoutingLogic: AnyObject {
    
    var navigationController: UINavigationController? { get set }
    
    func routeToAuth()
    
    func routeToChangeSettings()
    
    func routeToUserSettings()
}
