//
//  TabBarScreenProtocols.swift
//  CoLab
//
//  Created by User on 07.03.2026.
//

import Foundation

// Описывает бизнес логику экрана
protocol TabBarBusinessLogic: AnyObject {
    typealias Model = TabBarScreenModels
    
    func loadStart()
}

// Описывает логику презентации
protocol TabBarPresentationLogic: AnyObject {
    typealias Model = TabBarScreenModels
    
    func presentStart(_ response: Model.Start.Response)
}

// Описывает логику отображения
protocol TabBarDisplayLogic: AnyObject {
    typealias Model = TabBarScreenModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
}
