//
//  PhotoDetailViewModelTests.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import XCTest
@testable import FlickrSearch

@MainActor
final class PhotoDetailViewModelTests: XCTestCase {
    var sut: PhotoDetailViewModel!
    var mockAPIService: MockFlickrAPIService!
    var mockPhoto: FlickrPhoto!

    override func setUp() {
        super.setUp()
        mockAPIService = MockFlickrAPIService()
        mockPhoto = TestHelpers.createMockPhoto(id: "123")
        sut = PhotoDetailViewModel(photo: mockPhoto, apiService: mockAPIService)
    }

    override func tearDown() {
        sut = nil
        mockAPIService = nil
        mockPhoto = nil
        super.tearDown()
    }

    func testLoadPhotoInfo_Success_UpdatesPhotoInfo() async {
        // Given
        let mockInfo = TestHelpers.createMockPhotoInfo(photoId: "123")
        mockAPIService.getPhotoInfoResult = .success(mockInfo)

        // When
        await sut.loadPhotoInfo()

        // Then
        XCTAssertNotNil(sut.photoInfo)
        XCTAssertEqual(sut.photoInfo?.id, "123")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadPhotoInfo_Failure_SetsErrorMessage() async {
        // Given
        mockAPIService.getPhotoInfoResult = .failure(NetworkError.serverError(404))

        // When
        await sut.loadPhotoInfo()

        // Then
        XCTAssertNil(sut.photoInfo)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadPhotoInfo_CallsAPIWithCorrectPhotoId() async {
        // Given
        let mockInfo = TestHelpers.createMockPhotoInfo(photoId: "123")
        mockAPIService.getPhotoInfoResult = .success(mockInfo)

        // When
        await sut.loadPhotoInfo()

        // Then
        XCTAssertTrue(mockAPIService.getPhotoInfoCalled)
    }
}
