import SwiftUI

struct GeneratedCapsuleDetailView: View {
    let capsule: GeneratedCapsuleModel

    // Cached entries (avoid re-reading JSON for every cell)
    private var entriesByID: [String: PhotoMetadataCacheEntry] {
        let cache = PhotoCacheStore.shared.loadCache()
        return Dictionary(uniqueKeysWithValues: cache.map { ($0.id, $0) })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Cover thumbnail
                GeneratedCapsuleThumbnailView(filename: capsule.coverPhoto)
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top, 12)

                // Title + metadata
                VStack(alignment: .leading, spacing: 8) {
                    Text(capsule.name)
                        .font(.largeTitle.bold())

                    Text("\(capsule.photoCount) photos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Generated on \(formatted(capsule.generatedAt))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Divider().padding(.horizontal)

                // ⭐ REAL CLUSTERED PHOTOS
                VStack(alignment: .leading, spacing: 12) {
                    Text("Photos in this capsule")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)]) {
                        ForEach(capsule.photoIDs, id: \.self) { id in
                            
                            if let entry = entriesByID[id],
                               let image = PhotoCacheStore.shared.loadThumbnail(filename: entry.thumbnailFilename) {

                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                // placeholder if missing
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 80)
            }
        }
        .navigationTitle("Generated Capsule")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
