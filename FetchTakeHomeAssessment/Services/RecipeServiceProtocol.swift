//
//  RecipeServiceProtocol.swift
//  FetchTakeHomeAssessment
//
//  Created by Arnav Varyani on 6/2/25.
//

/// A protocol defining the contract for fetching recipes from a data source.
protocol RecipeServiceProtocol {
    /// Fetches a list of recipes asynchronously.
    /// - Returns: An array of `Recipe` objects.
    /// - Throws: A `RecipeServiceError` if the fetch operation fails.
    func fetchRecipes() async throws -> Recipes
}
