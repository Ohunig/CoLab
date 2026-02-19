//
//  AuthMainScreenControllerLogic.swift
//  CoLab
//
//  Created by User on 03.02.2026.
//

import Foundation

protocol AuthMainScreenControllerLogic: AnyObject {
    typealias Model = AuthMainScreenModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
}
