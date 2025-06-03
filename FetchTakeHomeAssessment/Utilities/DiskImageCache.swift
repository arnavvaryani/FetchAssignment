//
//  DiskImageCache 2.swift
//  FetchTakeHomeAssessment
//
//  Created by Arnav Varyani on 6/2/25.
//


import Foundation
import UIKit

/// Actor-based disk cache for storing and retrieving UIImages using UUID keys.

actor DiskImageCache {
    static let shared = DiskImageCache()
    
    private let directoryURL: URL
    
    private init() {
        // Create “Caches/<bundleID>/Images” directory if it doesn’t exist.
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "RecipesApp"
        directoryURL = caches
            .appendingPathComponent(bundleID)
            .appendingPathComponent("Images")
        
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("Failed to create Image cache directory: \(error)")
            }
        }
    }
    
    /// Returns the file URL for a given UUID and optional imageType suffix.
    private func fileURL(for uuid: UUID, imageType: String? = nil) -> URL {
        if let type = imageType {
            return directoryURL.appendingPathComponent("\(uuid.uuidString)-\(type).jpg")
        } else {
            return directoryURL.appendingPathComponent("\(uuid.uuidString).jpg")
        }
    }
        
    /// Checks whether a cached image file exists.
    func imageExists(for uuid: UUID, imageType: String? = nil) async -> Bool {
        let url = fileURL(for: uuid, imageType: imageType)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// Loads a UIImage from disk if it exists, otherwise returns nil.
    func loadImage(for uuid: UUID, imageType: String? = nil) async -> UIImage? {
        let url = fileURL(for: uuid, imageType: imageType)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }
    
    /// Saves a UIImage to disk under “<uuid>.jpg” or “<uuid>-<imageType>.jpg”.
    func saveImage(_ image: UIImage, for uuid: UUID, imageType: String? = nil) async throws {
        let url = fileURL(for: uuid, imageType: imageType)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(
                domain: "DiskImageCache",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to JPEG data"]
            )
        }
        try data.write(to: url, options: .atomic)
    }
    
    /// Removes any cached image file for the given UUID (ignoring imageType).
    func removeImage(for uuid: UUID) async throws {
        let url = fileURL(for: uuid, imageType: nil)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        
        // Also attempt removal of “-large” suffix if present
        let largeURL = fileURL(for: uuid, imageType: "large")
        if FileManager.default.fileExists(atPath: largeURL.path) {
            try FileManager.default.removeItem(at: largeURL)
        }
    }
    
    // MARK: - Unified Load Helper
    
    /// Attempts to load from disk first; if missing, fetches from network, caches, and returns the UIImage.
    /// - Parameters:
    ///   - uuid: Cache key (UUID).
    ///   - url: Remote image URL to download if not on disk.
    ///   - imageType: Optional suffix (e.g., “large” or nil for thumbnail).
    /// - Returns: The cached or freshly downloaded UIImage, or nil on failure.
    private func loadOrFetchImage(
        uuid: UUID,
        from url: URL,
        imageType: String? = nil
    ) async -> UIImage? {
        // If file already exists on disk, load & return immediately.
        if let existing = await loadImage(for: uuid, imageType: imageType) {
            return existing
        }
        
        // Otherwise, download data using URLSession.
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                print("Failed to create UIImage from downloaded data at \(url).")
                return nil
            }

            do {
                try await saveImage(image, for: uuid, imageType: imageType)
            } catch {
                print("Warning: Unable to save image to disk: \(error)")
            }
            return image
        } catch {
            print("Failed to fetch image from \(url): \(error)")
            return nil
        }
    }
    
    func loadLargeImage(for uuid: UUID, from url: URL) async -> UIImage? {
        return await loadOrFetchImage(uuid: uuid, from: url, imageType: "large")
    }
}
