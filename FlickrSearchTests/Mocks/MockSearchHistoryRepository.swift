//
//  MockSearchHistoryRepository.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

@testable import FlickrSearch

final class MockSearchHistoryRepository: SearchHistoryRepositoryProtocol {
    var savedSearches: [String] = []
    var lastSearch: String?

    func saveLastSearch(_ query: String) {
        savedSearches.append(query)
        lastSearch = query
    }

    func getLastSearch() -> String? {
        return lastSearch
    }
}
