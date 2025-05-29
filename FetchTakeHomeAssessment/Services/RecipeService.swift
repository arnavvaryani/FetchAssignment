//
//  RecipeService.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 6/2/25.
//

import SwiftUI

class RecipeService {
    static let shared = RecipeService()
    private init() {}
    
    private let endpointString = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    
    /// Fetches and decodes the recipes list.
    func fetchRecipes() async throws -> [Recipe] {
        guard let url = URL(string: endpointString) else {
            throw RecipeServiceError.invalidURL
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let wrapper = try decoder.decode(RecipeResponse.self, from: data)
            return wrapper.recipes
        } catch let urlErr as URLError {
            throw RecipeServiceError.network(urlErr)
        } catch let decErr as DecodingError {
            throw RecipeServiceError.decoding(decErr)
        } catch {
            throw RecipeServiceError.unknown(error)
        }
    }
}
