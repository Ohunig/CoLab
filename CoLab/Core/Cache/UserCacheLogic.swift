//
//  UserChacheLogic.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

// Логика хранения кэша юзера
protocol UserCacheLogic: AnyObject {
    
    func update(user: UserModel, for userId: String)
    
    func getUser(with userId: String) -> UserModel?
    
    func clear()
}
