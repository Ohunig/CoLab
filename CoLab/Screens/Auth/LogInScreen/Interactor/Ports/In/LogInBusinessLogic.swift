//
//  LogInBusinessLogic.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

protocol LogInBusinessLogic: AnyObject {
    typealias Model = LogInModels
    
    func loadStart()
    
    func loadLogIn(_ request: Model.LogIn.Request)
    
    func loadAuthMainScreen()
}
