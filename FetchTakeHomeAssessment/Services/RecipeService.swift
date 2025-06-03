//
//  RecipeService.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 6/2/25.
//

import SwiftUI

/// A service responsible for fetching and decoding recipe data from a remote API.
class RecipeService: RecipeServiceProtocol {
    
    // MARK: - API Endpoints for Testing
    // Use one of the following endpoints based on the test scenario:
    // 1. Malformed JSON: https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json
    // 2. Empty response: https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json
    // 3. Valid data:     https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json
    
    /// Shared singleton instance for global access.
    static let shared = RecipeService()
    
    /// URLSession used for performing network requests. Can be injected for testing.
    private let session: URLSession
    
    /// The endpoint string pointing to the JSON data source.
    private let endpointString : String
    
    /// Initializes the service with a specified URLSession. Defaults to `.shared`.
    /// - Parameter session: A URLSession instance
    init(session: URLSession = .shared, endpointString: String = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    ) {
        self.session = session
        self.endpointString = endpointString
    }
    
    /// Fetches a list of recipes from the configured endpoint.
    ///
    /// - Returns: An array of `Recipe` instances decoded from the server response.
    /// - Throws: `RecipeServiceError` if the request fails, decoding fails, or an unknown error occurs.
    func fetchRecipes() async throws -> Recipes {
        guard let url = URL(string: endpointString) else {
            throw RecipeServiceError.invalidURL
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(RecipeResponse.self, from: data)
            return response.recipes
        } catch let urlErr as URLError {
            throw RecipeServiceError.network(urlErr)
        } catch let decErr as DecodingError {
            throw RecipeServiceError.decoding(decErr)
        } catch {
            throw RecipeServiceError.unknown(error)
        }
    }
}

