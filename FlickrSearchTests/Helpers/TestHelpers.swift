//
//  TestHelpers.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

@testable import FlickrSearch

struct TestHelpers {
    static func createMockPhoto(
        id: String = "123",
        title: String = "Test Photo",
        server: String = "65535",
        secret: String = "abc123"
    ) -> FlickrPhoto {
        FlickrPhoto(
            id: id,
            owner: "owner123",
            secret: secret,
            server: server,
            farm: 1,
            title: title,
            ispublic: 1,
            isfriend: 0,
            isfamily: 0
        )
    }

    static func createMockSearchResponse(
        photos: [FlickrPhoto],
        page: Int = 1,
        pages: Int = 5,
        perPage: Int = 20
    ) -> FlickrSearchResponse {
        FlickrSearchResponse(
            photos: FlickrPhotos(
                page: page,
                pages: pages,
                perpage: perPage,
                total: photos.count,
                photo: photos
            ),
            stat: "ok"
        )
    }

    static func createMockPhotoInfo(photoId: String = "123") -> FlickrPhotoInfo {
        FlickrPhotoInfo(
            photo: FlickrPhotoDetail(
                id: photoId,
                owner: FlickrOwner(
                    nsid: "owner123",
                    username: "testuser",
                    realname: "Test User"
                ),
                title: FlickrContent(_content: "Test Photo Title"),
                description: FlickrContent(_content: "Test description"),
                dates: FlickrDates(
                    posted: "1609459200",
                    taken: "2021-01-01 12:00:00"
                ),
                views: "1234"
            ),
            stat: "ok"
        )
    }
}
