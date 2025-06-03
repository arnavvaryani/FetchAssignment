//
//  RecipeViewModel.swift
//  FetchTakeHomeAssessment
//
//  Created by Arnav Varyani on 6/2/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
class RecipeViewModel {
    var recipes: Recipes = []
    var errorMessage: String?
    var images: [UUID: UIImage] = [:]
    var searchText: String = ""
    var sortOption: SortOption = .name
    var isLoading: Bool = false
    
    var filteredAndSortedRecipes: Recipes {
        let filtered: Recipes
        if searchText.isEmpty {
            filtered = recipes
        } else {
            filtered = recipes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.cuisine.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { a, b in
            switch sortOption {
            case .name:
                return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            case .cuisine:
                return a.cuisine.localizedCaseInsensitiveCompare(b.cuisine) == .orderedAscending
            }
        }
    }
    
    var hasError: Bool {
        errorMessage != nil
    }
    
    var isEmpty: Bool {
        recipes.isEmpty && !isLoading && !hasError
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Name"
        case cuisine = "Cuisine"
        var id: String { rawValue }
    }
    
    private let service: RecipeServiceProtocol
    private let imageCache = DiskImageCache.shared
    
    init(service: RecipeServiceProtocol = RecipeService.shared) {
        self.service = service
    }
    
    @MainActor
    func loadRecipesFromAPI() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch recipes
            recipes = try await service.fetchRecipes()
            
            // Load images concurrently
            await loadImagesForRecipes()
        } catch {
            recipes = []
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func refreshRecipes() async {
        await loadRecipesFromAPI()
    }
    
    func hasImage(for recipeId: UUID) -> Bool {
        images[recipeId] != nil
    }
    
    func image(for recipeId: UUID) -> UIImage? {
        images[recipeId]
    }
    
    @MainActor
    private func loadImagesForRecipes() async {
        await withTaskGroup(of: (UUID, UIImage?).self) { group in
            for recipe in recipes {
                group.addTask { [weak self] in
                    guard let self = self else { return (recipe.uuid, nil) }
                    
                    // Check cache first
                    if await self.imageCache.imageExists(for: recipe.uuid) {
                        let img = await self.imageCache.loadImage(for: recipe.uuid)
                        return (recipe.uuid, img)
                    }
                    
                    // Download small image for list view
                    guard let url = recipe.photoURLSmall ?? recipe.photoURLLarge else {
                        return (recipe.uuid, nil)
                    }
                    
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let img = UIImage(data: data) {
                            try await self.imageCache.saveImage(img, for: recipe.uuid)
                            return (recipe.uuid, img)
                        }
                    } catch {
                        print("Failed to load image for \(recipe.uuid): \(error)")
                    }
                    return (recipe.uuid, nil)
                }
            }
            
            for await (uuid, maybeImage) in group {
                if let img = maybeImage {
                    images[uuid] = img
                }
            }
        }
    }
}
