//
//  UserCacheStorage.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

final class UserCacheStorage: UserCacheLogic {
    
    private enum Constants {
        static let storageFolder = "UserCache"
        static let fileExtension = "json"
        static let queueLabel = "com.colab.UserCacheStorage.queue"
    }
   
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let fileManager = FileManager.default
    // Очередь для синхронизации доступа
    private let queue = DispatchQueue(label: Constants.queueLabel)
    
    private var cacheDirectory: URL {
        let base = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(Constants.storageFolder, isDirectory: true)
    }
    
    // MARK: Lifecycle

    init() {
        // Если try? вернёт nil -> сервис не будет работать. Было принято решение оставить это так как в таком случае данные просто будут подгружаться из сети
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: Use cases

    func update(user: UserModel, for userId: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let url = self.fileURL(for: userId)
            let data = try? self.encoder.encode(user)
            try? data?.write(to: url, options: .atomic)
        }
    }

    func getUser(with userId: String) -> UserModel? {
        return queue.sync {
            let url = fileURL(for: userId)
            guard let data = try? Data(contentsOf: url) else { return nil }
            return try? decoder.decode(UserModel.self, from: data)
        }
    }

    func clear() {
        queue.async { [weak self] in
            guard let self = self else { return }
            try? fileManager.removeItem(at: cacheDirectory)
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: Helpers
        
    private func fileURL(for userId: String) -> URL {
        return cacheDirectory.appendingPathComponent(userId).appendingPathExtension(Constants.fileExtension)
    }

}
