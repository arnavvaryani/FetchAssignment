//
//  RecipeDetailViewModel.swift
//  FetchTakeHomeAssessment
//
//  Created by Arnav Varyani on 6/2/25.
//


import Foundation
import SwiftUI
import Observation

@Observable
class RecipeDetailViewModel {
    let recipe: Recipe
    let smallImage: UIImage?
    private(set) var largeImage: UIImage?
    private(set) var isLoadingLarge = false
    
    private let imageCache = DiskImageCache.shared
    
    var displayImage: UIImage? {
        largeImage ?? smallImage
    }
    
    var hasSourceURL: Bool {
        recipe.sourceURL != nil
    }
    
    var hasYouTubeURL: Bool {
        recipe.youtubeURL != nil
    }
    
    var showLoadingIndicator: Bool {
        isLoadingLarge && smallImage != nil && largeImage == nil
    }
    
    init(recipe: Recipe, cachedSmallImage: UIImage?) {
        self.recipe = recipe
        self.smallImage = cachedSmallImage
    }
    
    @MainActor
    func loadLargeImageIfNeeded() async {
        // Skip if we already have the large image or no large URL exists
        guard largeImage == nil,
              let largeURL = recipe.photoURLLarge else {
            return
        }
        
        isLoadingLarge = true
        
        // Load large image from cache or network
        if let image = await imageCache.loadLargeImage(for: recipe.uuid, from: largeURL) {
            largeImage = image
        }
        
        isLoadingLarge = false
    }
}
