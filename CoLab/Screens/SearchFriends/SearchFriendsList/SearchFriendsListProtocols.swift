//
//  SearchFriendsListProtocols.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import Foundation

protocol SearchFriendsListBusinessLogic: AnyObject {
    typealias Model = SearchFriendsListModels
    
    func loadStart()
    
    func listenCurrentUserAvatar()
    
    func stopListeningCurrentUserAvatar()
    
    func loadInitialUsers()
    
    func loadNextPage()
    
    func updateSearchText(_ text: String)
}

protocol SearchFriendsListTableDataLogic: AnyObject {
    typealias Model = SearchFriendsListModels
    
    func userIds() -> [String]
    
    func item(for userId: String) -> Model.UsersList.ViewModel.UserCell?
}

protocol SearchFriendsListPresentationLogic: AnyObject {
    typealias Model = SearchFriendsListModels
    
    func presentStart(_ response: Model.Start.Response)
    
    func presentCurrentUserAvatar(_ response: Model.CurrentUserAvatar.Response)
    
    func presentUsers(_ response: Model.UsersList.Response)
    
    func presentAvatarUpdate(_ response: Model.AvatarUpdate.Response)
    
    func presentError(_ response: Model.ShowError.Response)
}

protocol SearchFriendsListDisplayLogic: AnyObject {
    typealias Model = SearchFriendsListModels
    
    func displayStart(_ viewModel: Model.Start.ViewModel)
    
    func displayCurrentUserAvatar(_ viewModel: Model.CurrentUserAvatar.ViewModel)
    
    func displayUsers(_ viewModel: Model.UsersList.ViewModel)
    
    func displayAvatarUpdate(_ viewModel: Model.AvatarUpdate.ViewModel)
    
    func displayError(_ viewModel: Model.ShowError.ViewModel)
}
