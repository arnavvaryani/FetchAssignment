//
//  RecipeViewModel.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 6/2/25.
//


import Foundation

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var errorMessage: String?

    func loadRecipesFromAPI() async {
        do {
            let recipesfromAPI = try await RecipeService.shared.fetchRecipes()
            self.recipes = recipesfromAPI
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to fetch recipes: \(error.localizedDescription)"
        }
    }
}
