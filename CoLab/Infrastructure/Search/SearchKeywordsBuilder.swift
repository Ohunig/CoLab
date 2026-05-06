//
//  SearchKeywordsBuilder.swift
//  CoLab
//
//  Created by User on 05.05.2026.
//

import Foundation

struct SearchKeywordsBuilder {
    private let maxWords: Int
    
    init(maxWords: Int = 20) {
        self.maxWords = maxWords
    }
    
    func queryWords(for text: String?) -> [String] {
        words(from: text)
    }
    
    func keywords(for text: String) -> [String] {
        var usedKeywords = Set<String>()
        
        return words(from: text).reduce(into: []) { result, word in
            for length in 1...word.count {
                let keyword = String(word.prefix(length))
                guard usedKeywords.insert(keyword).inserted else { continue }
                
                result.append(keyword)
            }
        }
    }
    
    private func words(from text: String?) -> [String] {
        let separators = CharacterSet.whitespacesAndNewlines
            .union(.punctuationCharacters)
        
        let words = text?
            .lowercased()
            .components(separatedBy: separators)
            .filter { !$0.isEmpty } ?? []
        
        var usedWords = Set<String>()
        
        return words.reduce(into: []) { result, word in
            guard result.count < maxWords else { return }
            guard usedWords.insert(word).inserted else { return }
            
            result.append(word)
        }
    }
}
