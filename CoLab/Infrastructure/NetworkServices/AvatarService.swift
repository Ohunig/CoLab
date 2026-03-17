//
//  AvatarService.swift
//  CoLab
//
//  Created by User on 11.03.2026.
//

import Foundation
import Combine
import Supabase


final class AvatarService: AvatarServiceLogic {
    
    private struct Constants {
        static let supabaseKey = "sb_publishable_sbdRi5n-wqtUQE36t94NCg_gx_MTMiK"
        
        static let contentType = "image/jpeg"
    }
    
    // Так как supabase используется только в данном сервисе то нет нужды в отдельных сервисах для обработки всего этого. (Вынужденная мера использовать supabase так как нет возможности использовать firebase полностью)
    private let supabase: SupabaseClient? = {
        guard let url = URL(string: SupabasePath.base.path) else {
            return nil
        }
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: Constants.supabaseKey,
            options: .init(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }()
    
    private let avatarsCache: AvatarsCacheLogic
    
    private var inflightPublishers: [String: AnyPublisher<Data?, Never>] = [:]
    private var keepAlives: [String: AnyCancellable] = [:]
    
    // MARK: Init
    
    init(avatarsCache: AvatarsCacheLogic) {
        self.avatarsCache = avatarsCache
    }
    
    // MARK: Use cases
    
    func avatarDataPublisher(photoURL: String) -> AnyPublisher<Data?, Never> {
        // Пытаемся подтянуть сохранённые данные
        if let cachedData = avatarsCache.getAvatar(from: photoURL) {
            return Just(cachedData).eraseToAnyPublisher()
        }
        
        if let existing = inflightPublishers[photoURL] {
            return existing
        }
        
        guard let url = URL(string: SupabasePath.avatar(path: photoURL).path)
        else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        let publisher = URLSession.shared
            .dataTaskPublisher(for: url)
            .map { data, _ in data}
            .handleEvents(receiveOutput: { [weak self] data in
                guard let data else { return }
                self?.avatarsCache.saveAvatar(data: data, with: photoURL)
            }, receiveCompletion: { [weak self] _ in
                self?.inflightPublishers.removeValue(forKey: photoURL)
                self?.keepAlives.removeValue(forKey: photoURL)
            })
            .replaceError(with: nil)
            .share()
            .eraseToAnyPublisher()
        inflightPublishers[photoURL] = publisher
        // Удерживаем чтобы запрос в любом случае выполнился до конца
        let keep = publisher.sink { _ in }
        keepAlives[photoURL] = keep
        
        return publisher
    }
    
    func uploadUserAvatarData(
        data: Data,
        for userId: String
    ) -> AnyPublisher<String, Error> {
        
        let fileName = "\(userId)-\(Int(Date().timeIntervalSince1970)).jpg"
        
        return Future { promise in
            // Используется async/await так как supabase работает с таким api. Это никак не мешает использовать GCD в остальном коде
            Task {
                do {
                    try await self.supabase?.storage
                        .from(SupabaseBucket.avatars.path)
                        .update(
                            fileName,
                            data: data,
                            options: FileOptions(contentType: Constants.contentType)
                        )
                    
                    self.avatarsCache.saveAvatar(data: data, with: fileName)
                    
                    promise(.success(fileName))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func clearAvatarsCache() {
        avatarsCache.clear()
    }
}
