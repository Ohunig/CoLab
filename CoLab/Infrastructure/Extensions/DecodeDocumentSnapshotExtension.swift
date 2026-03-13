//
//  DecodeDocumentSnapshotExtension.swift
//  CoLab
//
//  Created by User on 12.03.2026.
//

import Foundation
import FirebaseFirestore

extension DocumentSnapshot {
    private struct Constants {
        static let standardIdKey = "id"
    }
    
    func decoded<T: Decodable>(
        _ type: T.Type,
        idKey: String? = Constants.standardIdKey,
        dateAsSeconds: Bool = true,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        var raw = self.data() ?? [:]
        // Вставляем documentID
        if let idKey = idKey {
            raw[idKey] = self.documentID
        }
        // Преобразуем в Data и декодируем
        let jsonData = try JSONSerialization.data(withJSONObject: raw, options: [])
        return try decoder.decode(T.self, from: jsonData)
    }
}
