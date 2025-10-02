//
//  PhotoSearchViewModelTests.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import XCTest
@testable import FlickrSearch

@MainActor
final class PhotoSearchViewModelTests: XCTestCase {
    var sut: PhotoSearchViewModel!
    var mockAPIService: MockFlickrAPIService!
    var mockHistoryRepository: MockSearchHistoryRepository!

    override func setUp() {
        super.setUp()
        mockAPIService = MockFlickrAPIService()
        mockHistoryRepository = MockSearchHistoryRepository()
        sut = PhotoSearchViewModel(
            apiService: mockAPIService,
            historyRepository: mockHistoryRepository
        )
    }

    override func tearDown() {
        sut = nil
        mockAPIService = nil
        mockHistoryRepository = nil
        super.tearDown()
    }

    // MARK: - Initial Load Tests

    func testLoadInitialData_WithNoHistory_SearchesDog() async {
        // Given
        let mockPhotos = [
            TestHelpers.createMockPhoto(id: "1"),
            TestHelpers.createMockPhoto(id: "2")
        ]
        let mockResponse = TestHelpers.createMockSearchResponse(photos: mockPhotos)
        mockAPIService.searchPhotosResult = .success(mockResponse)

        // When
        await sut.loadInitialData()

        // Then
        XCTAssertEqual(sut.searchText, "dog")
        XCTAssertEqual(mockAPIService.lastSearchQuery, "dog")
        XCTAssertEqual(sut.photos.count, 2)
    }

    func testLoadInitialData_WithHistory_SearchesLastQuery() async {
        // Given
        mockHistoryRepository.lastSearch = "cats"
        let mockPhotos = [TestHelpers.createMockPhoto()]
        let mockResponse = TestHelpers.createMockSearchResponse(photos: mockPhotos)
        mockAPIService.searchPhotosResult = .success(mockResponse)

        // When
        await sut.loadInitialData()

        // Then
        XCTAssertEqual(sut.searchText, "cats")
        XCTAssertEqual(mockAPIService.lastSearchQuery, "cats")
    }

    // MARK: - Search Tests

    func testSearchPhotos_Success_UpdatesPhotos() async {
        // Given
        let mockPhotos = [
            TestHelpers.createMockPhoto(id: "1", title: "Photo 1"),
            TestHelpers.createMockPhoto(id: "2", title: "Photo 2")
        ]
        let mockResponse = TestHelpers.createMockSearchResponse(photos: mockPhotos)
        mockAPIService.searchPhotosResult = .success(mockResponse)

        // When
        await sut.searchPhotos(query: "sunset", resetResults: true)

        // Then
        XCTAssertEqual(sut.photos.count, 2)
        XCTAssertEqual(sut.photos[0].title, "Photo 1")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testSearchPhotos_Failure_SetsErrorMessage() async {
        // Given
        mockAPIService.searchPhotosResult = .failure(NetworkError.serverError(500))

        // When
        await sut.searchPhotos(query: "test", resetResults: true)

        // Then
        XCTAssertTrue(sut.photos.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testSearchPhotos_SavesSearchToHistory() async {
        // Given
        let mockResponse = TestHelpers.createMockSearchResponse(photos: [])
        mockAPIService.searchPhotosResult = .success(mockResponse)

        // When
        await sut.searchPhotos(query: "mountains", resetResults: true)

        // Then
        XCTAssertEqual(mockHistoryRepository.lastSearch, "mountains")
    }

    func testSearchPhotos_EmptyQuery_DoesNothing() async {
        // Given
        let initialPhotosCount = sut.photos.count

        // When
        await sut.searchPhotos(query: "", resetResults: true)

        // Then
        XCTAssertEqual(sut.photos.count, initialPhotosCount)
        XCTAssertFalse(mockAPIService.searchPhotosCalled)
    }

    // MARK: - Pagination Tests

    func testLoadMorePhotos_AppendsNewPhotos() async {
        // Given
        let firstBatch = [
            TestHelpers.createMockPhoto(id: "1"),
            TestHelpers.createMockPhoto(id: "2")
        ]
        let secondBatch = [
            TestHelpers.createMockPhoto(id: "3"),
            TestHelpers.createMockPhoto(id: "4")
        ]

        let firstResponse = TestHelpers.createMockSearchResponse(photos: firstBatch, page: 1)
        let secondResponse = TestHelpers.createMockSearchResponse(photos: secondBatch, page: 2)

        mockAPIService.searchPhotosResult = .success(firstResponse)
        await sut.searchPhotos(query: "test", resetResults: true)

        mockAPIService.searchPhotosResult = .success(secondResponse)

        // When
        await sut.loadMorePhotos()

        // Then
        XCTAssertEqual(sut.photos.count, 4)
        XCTAssertEqual(mockAPIService.lastSearchPage, 2)
    }

    func testLoadMorePhotos_WhenLoading_DoesNotLoadMore() async {
        // Given
        sut.isLoading = true
        let initialCount = sut.photos.count

        // When
        await sut.loadMorePhotos()

        // Then
        XCTAssertEqual(sut.photos.count, initialCount)
    }

    func testLoadMorePhotos_WhenNoMorePages_DoesNotLoadMore() async {
        // Given
        let mockPhotos = [TestHelpers.createMockPhoto()]
        let mockResponse = TestHelpers.createMockSearchResponse(
            photos: mockPhotos,
            page: 5,
            pages: 5
        )
        mockAPIService.searchPhotosResult = .success(mockResponse)
        await sut.searchPhotos(query: "test", resetResults: true)

        let initialCount = sut.photos.count

        // When
        await sut.loadMorePhotos()

        // Then
        XCTAssertEqual(sut.photos.count, initialCount)
        XCTAssertFalse(sut.hasMorePages)
    }

    func testHasMorePages_UpdatesCorrectly() async {
        // Given
        let mockPhotos = [TestHelpers.createMockPhoto()]
        let mockResponse = TestHelpers.createMockSearchResponse(
            photos: mockPhotos,
            page: 1,
            pages: 3
        )
        mockAPIService.searchPhotosResult = .success(mockResponse)

        // When
        await sut.searchPhotos(query: "test", resetResults: true)

        // Then
        XCTAssertTrue(sut.hasMorePages)
    }
}
