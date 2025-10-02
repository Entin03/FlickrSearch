//
//  FlickrPhotoTests.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import XCTest
@testable import FlickrSearch

final class FlickrPhotoTests: XCTestCase {
    func testThumbnailURL_GeneratesCorrectURL() {
        // Given
        let photo = TestHelpers.createMockPhoto(
            id: "123",
            server: "65535",
            secret: "abc123"
        )

        // When
        let url = photo.thumbnailURL

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("123_abc123_w.jpg") ?? false)
    }

    func testLargeImageURL_GeneratesCorrectURL() {
        // Given
        let photo = TestHelpers.createMockPhoto(
            id: "456",
            server: "65535",
            secret: "def456"
        )

        // When
        let url = photo.largeImageURL

        // Then
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("456_def456_b.jpg") ?? false)
    }

    func testFlickrPhoto_Equatable() {
        // Given
        let photo1 = TestHelpers.createMockPhoto(id: "123")
        let photo2 = TestHelpers.createMockPhoto(id: "123")
        let photo3 = TestHelpers.createMockPhoto(id: "456")

        // Then
        XCTAssertEqual(photo1, photo2)
        XCTAssertNotEqual(photo1, photo3)
    }
}
