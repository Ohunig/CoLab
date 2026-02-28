//
//  LogInPresentationLogic.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

protocol LogInPresentationLogic: AnyObject {
    typealias Model = LogInModels

    func presentStart(_ response: Model.Start.Response)
    
    func presentDataValidation(_ response: Model.Validation.Response)
    
    func presentLogInResult(_ response: Model.LogIn.Response)
}
