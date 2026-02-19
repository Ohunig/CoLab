//
//  RegisterControllerLogic.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

protocol RegisterControllerLogic: AnyObject {
    typealias Model = RegisterModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayRegisterResult(_ viewModel: Model.SignUp.ViewModel)
}
