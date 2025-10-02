//
//  SearchHistoryRepositoryTests.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import XCTest
@testable import FlickrSearch

final class SearchHistoryRepositoryTests: XCTestCase {
    var sut: SearchHistoryRepository!
    var mockUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "TestDefaults")
        mockUserDefaults.removePersistentDomain(forName: "TestDefaults")
        sut = SearchHistoryRepository(userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "TestDefaults")
        sut = nil
        mockUserDefaults = nil
        super.tearDown()
    }

    func testSaveLastSearch_StoresQueryInUserDefaults() {
        // Given
        let query = "sunset"

        // When
        sut.saveLastSearch(query)

        // Then
        let saved = mockUserDefaults.string(forKey: "lastSearchQuery")
        XCTAssertEqual(saved, query)
    }

    func testGetLastSearch_ReturnsNilWhenNoSearchSaved() {
        // When
        let result = sut.getLastSearch()

        // Then
        XCTAssertNil(result)
    }

    func testGetLastSearch_ReturnsLastSavedQuery() {
        // Given
        let query = "mountains"
        sut.saveLastSearch(query)

        // When
        let result = sut.getLastSearch()

        // Then
        XCTAssertEqual(result, query)
    }

    func testSaveLastSearch_OverwritesPreviousSearch() {
        // Given
        sut.saveLastSearch("first")

        // When
        sut.saveLastSearch("second")

        // Then
        let result = sut.getLastSearch()
        XCTAssertEqual(result, "second")
    }
}
