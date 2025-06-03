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
        
        try? await cache.removeImage(for: tempUUID)
        
        #expect(!(await cache.imageExists(for: tempUUID)))
        
        let maybeImage = await cache.loadImage(for: tempUUID)
        #expect(maybeImage == nil)
    }
    
    @Test
    func saveAndLoadImageRoundtrip() async throws {
        let cache = DiskImageCache.shared
        let tempUUID = UUID()
        
        //
        try? await cache.removeImage(for: tempUUID)
        
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let redImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        try await cache.saveImage(redImage, for: tempUUID)
        
        #expect(await cache.imageExists(for: tempUUID))
        
        let loaded = try #require(await cache.loadImage(for: tempUUID))
        #expect(loaded.size == size)
        
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
        
        let badImage = UIImage()
        
        await #expect(throws: NSError.self) {
            try await cache.saveImage(badImage, for: tempUUID)
        }
    }
}



