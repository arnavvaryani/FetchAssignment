//
//  DiskImageCache.swift
//  FetchTakeHomeAssessment
//
//  Created by Arnav Varyani on 6/2/25.
//

import Foundation
import UIKit

actor DiskImageCache {
    static let shared = DiskImageCache()
    private let directoryURL: URL
    
    private init() {
        let caches = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
        
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
    
    private func fileURL(
        for uuid: UUID,
        imageType: String? = nil
    ) -> URL {
        if let type = imageType {
            return directoryURL
                .appendingPathComponent("\(uuid.uuidString)-\(type).jpg")
        } else {
            return directoryURL
                .appendingPathComponent("\(uuid.uuidString).jpg")
        }
    }
    
    /// Checks if an image (with optional `imageType` suffix) exists on disk.
    func imageExists(
        for uuid: UUID,
        imageType: String? = nil
    ) async -> Bool {
        let url = fileURL(for: uuid, imageType: imageType)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// Loads an image (with optional `imageType` suffix) from disk.
    func loadImage(
        for uuid: UUID,
        imageType: String? = nil
    ) async -> UIImage? {
        let url = fileURL(for: uuid, imageType: imageType)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        guard let data = try? Data(contentsOf: url),
              let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }
    
    /// Saves a `UIImage` under either `<uuid>.jpg` or `<uuid>-<imageType>.jpg
    func saveImage(
        _ image: UIImage,
        for uuid: UUID,
        imageType: String? = nil
    ) async throws {
        let url = fileURL(for: uuid, imageType: imageType)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(
                domain: "DiskImageCache",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to convert UIImage to JPEG data"
                ]
            )
        }
        try data.write(to: url, options: .atomic)
    }
    
    /// Removes any cached image (ignoring `imageType`; you can add an overload if needed).
    func removeImage(for uuid: UUID) async throws {
        let url = fileURL(for: uuid, imageType: nil)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
    
    /// High-level helper: “load from URL or cache if it exists” for the default (no `imageType`).
    func loadImageFromURL(
        _ url: URL,
        cacheKey: UUID
    ) async -> UIImage? {
        // If it’s already on disk, load & return
        if await imageExists(for: cacheKey, imageType: nil) {
            return await loadImage(for: cacheKey, imageType: nil)
        }
        
        // Otherwise, download, save, and return
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                print("Failed to create UIImage from downloaded data")
                return nil
            }
            try await saveImage(image, for: cacheKey, imageType: nil)
            return image
        }
        catch {
            print("Failed to download image from \(url): \(error)")
            return nil
        }
    }
    
    func loadLargeImage(
        for uuid: UUID,
        from url: URL
    ) async -> UIImage? {
        let type = "large"
        if await imageExists(for: uuid, imageType: type) {
            return await loadImage(for: uuid, imageType: type)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                print("Failed to create UIImage from downloaded data")
                return nil
            }
            try await saveImage(image, for: uuid, imageType: type)
            return image
        }
        catch {
            print("Failed to download large image: \(error)")
            return nil
        }
    }
    
    func loadSmallImage(
        for uuid: UUID,
        from url: URL
    ) async -> UIImage? {
        return await loadImageFromURL(url, cacheKey: uuid)
    }
}

