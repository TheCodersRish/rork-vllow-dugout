import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// Loads a picked Photos library video into a temporary file URL for AVFoundation.
struct Movie: Transferable {
    let url: URL

    nonisolated static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: UTType.movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let dest = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            try FileManager.default.copyItem(at: received.file, to: dest)
            return Movie(url: dest)
        }
    }
}
