//
//  PhotoDetailView.swift
//  FlickrSearch
//
//  Created by Valentin Taradáj on 2025. 10. 02..
//

import SwiftUI

struct PhotoDetailView: View {
    @StateObject private var viewModel: PhotoDetailViewModel
    @State private var scale: CGFloat = 1.0

    init(photo: FlickrPhoto) {
        _viewModel = StateObject(wrappedValue: PhotoDetailViewModel(photo: photo))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                zoomableImage

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if let photoInfo = viewModel.photoInfo {
                    photoDetails(photoInfo)
                }
            }
            .padding()
        }
        .navigationTitle("Photo Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadPhotoInfo()
        }
    }

    private var zoomableImage: some View {
        AsyncImage(url: viewModel.photo.largeImageURL) { phase in
            switch phase {
            case .empty:
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                    ProgressView()
                }
                .frame(height: 300)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3)) {
                                    scale = max(1.0, min(scale, 3.0))
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.3)) {
                            scale = scale == 1.0 ? 2.0 : 1.0
                        }
                    }
            case .failure:
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Failed to load")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 300)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func photoDetails(_ info: FlickrPhotoDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if !info.title._content.isEmpty {
                DetailRow(label: "Title", value: info.title._content)
            }

            if !info.description._content.isEmpty {
                DetailRow(label: "Description", value: info.description._content)
            }

            DetailRow(label: "Author", value: info.owner.username)

            if let realname = info.owner.realname, !realname.isEmpty {
                DetailRow(label: "Real Name", value: realname)
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Views")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(info.views)
                        .font(.body)
                        .fontWeight(.medium)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Posted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDate(info.dates.posted))
                        .font(.body)
                        .fontWeight(.medium)
                }
            }

            DetailRow(label: "Taken", value: info.dates.taken)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private func formatDate(_ timestamp: String) -> String {
        guard let timeInterval = TimeInterval(timestamp) else { return timestamp }
        let date = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .fontWeight(.semibold)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
