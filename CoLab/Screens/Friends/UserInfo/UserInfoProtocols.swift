//
//  UserInfoProtocols.swift
//  CoLab
//
//  Created by User on 08.05.2026.
//

import Foundation

protocol UserInfoBusinessLogic: AnyObject {
    typealias Model = UserInfoModels
    
    func loadStart()
    
    func closeScreen()
}

protocol UserInfoPresentationLogic: AnyObject {
    typealias Model = UserInfoModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentUserData(_ response: Model.UserData.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

protocol UserInfoDisplayLogic: AnyObject {
    typealias Model = UserInfoModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayUserData(_ viewModel: Model.UserData.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
