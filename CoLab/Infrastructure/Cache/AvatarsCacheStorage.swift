//
//  AvatarsCacheStorage.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import Foundation

final class AvatarCacheStorage: AvatarsCacheLogic {
    
    private enum Constants {
        static let storageFolder = "Avatars"
        static let fileExtension = "dat"
        static let queueLabel = "com.colab.AvatarsCacheStorage.queue"
    }
    
    private let fileManager = FileManager.default
    // Очередь для синхронизации доступа
    private let queue = DispatchQueue(label: Constants.queueLabel)
    
    private var cacheDirectory: URL {
        let base = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(
            Constants.storageFolder,
            isDirectory: true
        )
    }
    
    // MARK: Lifecycle
    
    init() {
        // Если try? вернёт nil -> сервис не будет работать. Было принято решение оставить это так как в таком случае данные просто будут подгружаться из сети
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: AvatarsCacheLogic
    
    func saveAvatar(data: Data, with urlString: String) {
        queue.async { [weak self] in
            guard let self else { return }
            let url = fileURL(for: urlString)
            try? data.write(to: url, options: .atomic)
        }
    }
    
    func getAvatar(from urlString: String) -> Data? {
        return queue.sync {
            let url = fileURL(for: urlString)
            return try? Data(contentsOf: url)
        }
    }
    
    func clear() {
        queue.async { [weak self] in
            guard let self else { return }
            // Попытка удалить
            try? fileManager.removeItem(at: cacheDirectory)
            // восстанавливаем пустую папку, чтобы сервис продолжил работать
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: Helpers
    
    private func fileURL(for urlString: String) -> URL {
        return cacheDirectory.appendingPathComponent(urlString).appendingPathExtension(Constants.fileExtension)
    }
}
