//
//  SupabasePath.swift
//  CoLab
//
//  Created by User on 11.03.2026.
//

import Foundation

// Эндпоинты для Supabase
enum SupabasePath {
    case base
    case avatar(path: String)
    
    var path: String {
        switch self {
        case .base:
            return "https://gcoxtqlomyqgofkjbwtn.supabase.co"
        case .avatar(let path):
            return Self.base.path + "/storage/v1/object/public/avatars/" + path
        }
    }
}

// Доступные хранилища Supabase
enum SupabaseBucket {
    case avatars
    
    var path: String {
        switch self {
        case .avatars:
            return "avatars"
        }
    }
}
