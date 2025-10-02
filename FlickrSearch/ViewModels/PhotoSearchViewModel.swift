//
//  PhotoSearchViewModel.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import Foundation

@MainActor
final class PhotoSearchViewModel: ObservableObject {
    @Published var photos: [FlickrPhoto] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true

    private let apiService: FlickrAPIServiceProtocol
    private let historyRepository: SearchHistoryRepositoryProtocol
    private var currentPage = 1
    private var totalPages = 1
    private var currentQuery = ""
    private let perPage = 20

    init(
        apiService: FlickrAPIServiceProtocol = FlickrAPIService(),
        historyRepository: SearchHistoryRepositoryProtocol = SearchHistoryRepository()
    ) {
        self.apiService = apiService
        self.historyRepository = historyRepository
    }

    func loadInitialData() async {
        let lastSearch = historyRepository.getLastSearch() ?? "dog"
        searchText = lastSearch
        await searchPhotos(query: lastSearch, resetResults: true)
    }

    func searchPhotos(query: String, resetResults: Bool = true) async {
        guard !query.isEmpty else { return }

        if resetResults {
            currentPage = 1
            totalPages = 1
            photos = []
            hasMorePages = true
        }

        currentQuery = query
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.searchPhotos(
                query: query,
                page: currentPage,
                perPage: perPage
            )

            currentPage = response.photos.page
            totalPages = response.photos.pages

            if resetResults {
                photos = response.photos.photo
            } else {
                photos.append(contentsOf: response.photos.photo)
            }

            hasMorePages = currentPage < totalPages
            historyRepository.saveLastSearch(query)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMorePhotos() async {
        guard !isLoading && hasMorePages else { return }
        currentPage += 1
        await searchPhotos(query: currentQuery, resetResults: false)
    }

    func performSearch() async {
        await searchPhotos(query: searchText, resetResults: true)
    }
}
