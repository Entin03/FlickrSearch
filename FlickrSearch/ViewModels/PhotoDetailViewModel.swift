//
//  PhotoDetailViewModel.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import Foundation

@MainActor
final class PhotoDetailViewModel: ObservableObject {
    @Published var photoInfo: FlickrPhotoDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let photo: FlickrPhoto
    private let apiService: FlickrAPIServiceProtocol

    init(photo: FlickrPhoto, apiService: FlickrAPIServiceProtocol = FlickrAPIService()) {
        self.photo = photo
        self.apiService = apiService
    }

    func loadPhotoInfo() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.getPhotoInfo(photoId: photo.id)
            photoInfo = response.photo
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
