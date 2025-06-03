//
//  DiskImageCacheTests.swift
//  FetchTakeHomeAssessment
//
//  Created by Arnav Varyani on 6/2/25.
//

import Testing
import UIKit
@testable import FetchTakeHomeAssessment

struct DiskImageCacheTests {
    
    @Test
    func imageDoesNotExistInitially() async throws {
        let cache = DiskImageCache.shared
        let tempUUID = UUID()
        
        // Ensure no leftover file
        try? await cache.removeImage(for: tempUUID)
        
        // Because imageExists(_:) is async, we must await it
        #expect(!(await cache.imageExists(for: tempUUID)))
        
        // loadImage(for:) is async as well
        let maybeImage = await cache.loadImage(for: tempUUID)
        #expect(maybeImage == nil)
    }
    
    @Test
    func saveAndLoadImageRoundtrip() async throws {
        let cache = DiskImageCache.shared
        let tempUUID = UUID()
        
        // Clean slate
        try? await cache.removeImage(for: tempUUID)
        
        // Create a 10×10 red UIImage
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let redImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Save the image (async throws)
        try await cache.saveImage(redImage, for: tempUUID)
        
        // Now it should exist on disk
        #expect(await cache.imageExists(for: tempUUID))
        
        // Load it back (async), unwrap, and verify size
        let loaded = try #require(await cache.loadImage(for: tempUUID))
        #expect(loaded.size == size)
        
        // Clean up
        try? await cache.removeImage(for: tempUUID)
    }
    
    @Test
    func removeImageDeletesFile() async throws {
        let cache = DiskImageCache.shared
        let tempUUID = UUID()
        
        // Save a dummy image so there is something to remove
        let dummy = UIImage(systemName: "star")!
        try await cache.saveImage(dummy, for: tempUUID)
        
        #expect(await cache.imageExists(for: tempUUID))
        
        // Now remove it
        try await cache.removeImage(for: tempUUID)
        
        #expect(!(await cache.imageExists(for: tempUUID)))
        
        // loadImage should return nil
        let maybeAfterRemoval = await cache.loadImage(for: tempUUID)
        #expect(maybeAfterRemoval == nil)
    }
    
    @Test
    func saveImageThrowsIfJPEGConversionFails() async throws {
        let cache = DiskImageCache.shared
        let tempUUID = UUID()
        
        // A “bad” UIImage (no underlying CGImage) will cause jpegData(compressionQuality:) to return nil
        let badImage = UIImage()
        
        // Because saveImage(_:for:) is now async throws, our expect block must await it.
        await #expect(throws: NSError.self) {
            try await cache.saveImage(badImage, for: tempUUID)
        }
    }
}



