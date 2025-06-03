//
//  RecipeServiceTests.swift
//  FetchTakeHomeAssessment
//
//  Created by Arnav Varyani on 6/2/25.
//

import Foundation
import Testing
@testable import FetchTakeHomeAssessment

struct RecipeServiceTests {

    @Test
    func fetchRecipesReturnsNonEmptyList() async throws {
        let service = RecipeService(endpointString: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
        let recipes = try await service.fetchRecipes()

        #expect(!recipes.isEmpty)
        let first = try #require(recipes.first)
        #expect(!first.name.isEmpty)
        #expect(!first.cuisine.isEmpty)
    }

    @Test
    func fetchRecipesReturnsEmptyListFromEmptyJSON() async throws {
        let service = RecipeService(endpointString: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")
        let recipes = try await service.fetchRecipes()
        #expect(recipes.isEmpty)
    }

    @Test
    func fetchRecipesThrowsOnMalformedJSON() async {
        let service = RecipeService(endpointString: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")

        do {
            _ = try await service.fetchRecipes()
            Issue.record("Expected decoding error but got success")
        } catch let error as RecipeServiceError {
            guard case .decoding = error else {
                Issue.record("Expected .decoding error but got \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}
