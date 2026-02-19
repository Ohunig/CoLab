//
//  RegisterBusinessLogic.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

protocol RegisterBusinessLogic: AnyObject {
    typealias Model = RegisterModels
    
    func loadStart()
    
    func loadRegister(request: Model.SignUp.Request)
    
    func loadAuthMainScreen()
}
