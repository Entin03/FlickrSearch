//
//  FlickrPhotoInfo.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

struct FlickrPhotoInfo: Codable {
    let photo: FlickrPhotoDetail
    let stat: String
}

struct FlickrPhotoDetail: Codable {
    let id: String
    let owner: FlickrOwner
    let title: FlickrContent
    let description: FlickrContent
    let dates: FlickrDates
    let views: String
}

struct FlickrOwner: Codable {
    let nsid: String
    let username: String
    let realname: String?
}

struct FlickrContent: Codable {
    let _content: String
}

struct FlickrDates: Codable {
    let posted: String
    let taken: String
}
