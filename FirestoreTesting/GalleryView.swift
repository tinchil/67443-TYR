//
//  GalleryView.swift
//  Saturdays
//
//  Created by Tin on 10/26/25.
//

import SwiftUI

struct GalleryView: View {
    @StateObject private var repo = ImageRepository()
    @State private var showingAddImageSheet = false
    @State private var caption = ""

    var body: some View {
        NavigationStack {
            VStack {
                if repo.images.isEmpty {
                    Text("No images yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(repo.images) { imageItem in
                            VStack {
                                AsyncImage(url: URL(string: imageItem.url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                } placeholder: {
                                    ProgressView()
                                }

                                Text(imageItem.caption)
                                    .font(.headline)
                                    .padding(.bottom, 8)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("My Images")
            .toolbar {
                Button {
                    showingAddImageSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .sheet(isPresented: $showingAddImageSheet) {
                AddImageView(repo: repo)
            }
        }
    }
}

// MARK: - Add Image Sheet
struct AddImageView: View {
    @ObservedObject var repo: ImageRepository
    @State private var caption = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Demo Image")
                .font(.title2)
                .bold()

            TextField("Caption", text: $caption)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                repo.addDemoImage(caption: caption) 
            }) {
                Text("Upload Sample Image")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}

