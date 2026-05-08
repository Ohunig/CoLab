//
//  AddFriendProtocols.swift
//  CoLab
//
//  Created by User on 06.05.2026.
//

import Foundation

protocol AddFriendBusinessLogic: AnyObject {
    typealias Model = AddFriendModels
    
    func loadStart()
    
    func addFriend()
}

protocol AddFriendPresentationLogic: AnyObject {
    typealias Model = AddFriendModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentUserData(_ response: Model.UserData.Response)
    
    func presentAddButtonState(_ response: Model.AddButtonState.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

protocol AddFriendDisplayLogic: AnyObject {
    typealias Model = AddFriendModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayUserData(_ viewModel: Model.UserData.ViewModel)
    
    func displayAddButtonState(_ viewModel: Model.AddButtonState.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
