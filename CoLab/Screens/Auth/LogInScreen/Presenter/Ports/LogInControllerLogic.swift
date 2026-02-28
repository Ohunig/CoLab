//
//  LogInControllerLogic.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

protocol LogInControllerLogic: AnyObject {
    typealias Model = LogInModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayDataValidation(_ viewModel: Model.Validation.ViewModel)
    
    func displayLogInResult(_ viewModel: Model.LogIn.ViewModel)
}
