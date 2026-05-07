//
//  AddChatMemberProtocols.swift
//  CoLab
//
//  Created by User on 07.05.2026.
//

import Foundation

protocol AddChatMemberBusinessLogic: AnyObject {
    typealias Model = AddChatMemberModels
    
    func loadStart()
    
    func addMember(userId: String)
}

protocol AddChatMemberTableDataLogic: AnyObject {
    typealias Model = AddChatMemberModels
    
    func userIds() -> [String]
    
    func item(for userId: String) -> Model.FriendsList.ViewModel.FriendCell?
}

protocol AddChatMemberPresentationLogic: AnyObject {
    typealias Model = AddChatMemberModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentFriends(_ response: Model.FriendsList.Response)
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response)
    
    func presentAddingState(_ response: Model.AddingState.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

protocol AddChatMemberDisplayLogic: AnyObject {
    typealias Model = AddChatMemberModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayFriends(_ viewModel: Model.FriendsList.ViewModel)
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel)
    
    func displayAddingState(_ viewModel: Model.AddingState.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
