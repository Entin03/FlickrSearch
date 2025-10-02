//
//  MockFlickrAPIService.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import Foundation
@testable import FlickrSearch

final class MockFlickrAPIService: FlickrAPIServiceProtocol {
    var searchPhotosResult: Result<FlickrSearchResponse, Error>?
    var getPhotoInfoResult: Result<FlickrPhotoInfo, Error>?
    var searchPhotosCalled = false
    var getPhotoInfoCalled = false
    var lastSearchQuery: String?
    var lastSearchPage: Int?

    func searchPhotos(query: String, page: Int, perPage: Int) async throws -> FlickrSearchResponse {
        searchPhotosCalled = true
        lastSearchQuery = query
        lastSearchPage = page

        guard let result = searchPhotosResult else {
            throw NetworkError.unknown(NSError(domain: "Test", code: 0))
        }

        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }

    func getPhotoInfo(photoId: String) async throws -> FlickrPhotoInfo {
        getPhotoInfoCalled = true

        guard let result = getPhotoInfoResult else {
            throw NetworkError.unknown(NSError(domain: "Test", code: 0))
        }

        switch result {
        case .success(let info):
            return info
        case .failure(let error):
            throw error
        }
    }
}
