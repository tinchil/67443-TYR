import SwiftUI

struct GeneratedCapsuleThumbnailView: View {
    let filename: String

    var body: some View {
        if let uiImage = loadFromDisk(filename: filename) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
        }
    }

    private func loadFromDisk(filename: String) -> UIImage? {
        guard !filename.isEmpty else { return nil }

        let url = PhotoCacheStore.shared.thumbnailDirectory
            .appendingPathComponent(filename)
        
        return UIImage(contentsOfFile: url.path)
    }
}
