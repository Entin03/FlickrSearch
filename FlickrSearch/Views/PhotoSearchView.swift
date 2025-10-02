//
//  PhotoSearchView.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import SwiftUI

struct PhotoSearchView: View {
    @StateObject private var viewModel = PhotoSearchViewModel()
    @State private var selectedPhoto: FlickrPhoto?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                if viewModel.isLoading && viewModel.photos.isEmpty {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else {
                    photoGrid
                }
            }
            .navigationTitle("Flickr Search")
            .navigationDestination(item: $selectedPhoto) { photo in
                PhotoDetailView(photo: photo)
            }
            .task {
                await viewModel.loadInitialData()
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))

            TextField("Search photos...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .font(.system(size: 16))
                .onSubmit {
                    Task {
                        await viewModel.performSearch()
                    }
                }

            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: viewModel.searchText.isEmpty)
    }

    private var photoGrid: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 8 + 8
            let spacing: CGFloat = 8
            let columnsCount: CGFloat = 3
            let totalSpacing = (columnsCount - 1) * spacing
            let availableWidth = geometry.size.width - horizontalPadding - 16
            let cellSide = floor((availableWidth - totalSpacing) / columnsCount)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSide), spacing: spacing), count: Int(columnsCount)), spacing: spacing) {
                    ForEach(viewModel.photos) { photo in
                        PhotoThumbnailView(photo: photo)
                            .frame(width: cellSide, height: cellSide)
                            .cornerRadius(8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedPhoto = photo
                            }
                            .onAppear {
                                if photo == viewModel.photos.last {
                                    Task { await viewModel.loadMorePhotos() }
                                }
                            }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)

                if viewModel.isLoading && !viewModel.photos.isEmpty {
                    ProgressView()
                        .padding()
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            Text("Loading photos...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            VStack(spacing: 8) {
                Text("Oops!")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                Task {
                    await viewModel.performSearch()
                }
            } label: {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding()
    }
}
