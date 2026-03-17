//
//  AvatarsCacheLogic.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

// Логика хранения кэша аватаров
protocol AvatarsCacheLogic: AnyObject {
    
    func saveAvatar(data: Data, with urlString: String)
    
    func getAvatar(from urlString: String) -> Data?
    
    func clear()
}
