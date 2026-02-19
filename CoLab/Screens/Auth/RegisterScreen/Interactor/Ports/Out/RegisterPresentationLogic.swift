//
//  RegisterPresentationLogic.swift
//  CoLab
//
//  Created by User on 05.02.2026.
//

import Foundation

protocol RegisterPresentationLogic: AnyObject {
    typealias Model = RegisterModels

    func presentStart(_ response: Model.Start.Response)
    
    func presentRegisterResult(_ response: Model.SignUp.Response)
}
