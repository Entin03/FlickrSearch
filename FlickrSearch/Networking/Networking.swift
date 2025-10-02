//
//  Networking.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import Foundation

protocol FlickrAPIServiceProtocol {
    func searchPhotos(query: String, page: Int, perPage: Int) async throws -> FlickrSearchResponse
    func getPhotoInfo(photoId: String) async throws -> FlickrPhotoInfo
}

final class FlickrAPIService: FlickrAPIServiceProtocol {
    private let apiKey = "65803e8f6e4a3982200621cad356be51"
    private let baseURL = "https://api.flickr.com/services/rest/"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchPhotos(query: String, page: Int = 1, perPage: Int = 20) async throws -> FlickrSearchResponse {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "text", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            return try decoder.decode(FlickrSearchResponse.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    func getPhotoInfo(photoId: String) async throws -> FlickrPhotoInfo {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.getInfo"),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "photo_id", value: photoId),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            return try decoder.decode(FlickrPhotoInfo.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
