//
//  FlickrSearchResponse.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import Foundation

struct FlickrSearchResponse: Codable {
    let photos: FlickrPhotos
    let stat: String
}

struct FlickrPhotos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int

    var thumbnailURL: URL? {
        URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_w.jpg")
    }

    var largeImageURL: URL? {
        URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_b.jpg")
    }

    var mediumImageURL: URL? {
        URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_z.jpg")
    }
}
