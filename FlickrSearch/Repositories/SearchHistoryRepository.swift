//
//  SearchHistoryRepository.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import Foundation

protocol SearchHistoryRepositoryProtocol {
    func saveLastSearch(_ query: String)
    func getLastSearch() -> String?
}

final class SearchHistoryRepository: SearchHistoryRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let lastSearchKey = "lastSearchQuery"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveLastSearch(_ query: String) {
        userDefaults.set(query, forKey: lastSearchKey)
    }

    func getLastSearch() -> String? {
        userDefaults.string(forKey: lastSearchKey)
    }
}
