//
//  RecipeResponse.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 5/29/25.
//

import Foundation

/// Represents the top-level JSON response from the recipes API.
struct RecipeResponse: Decodable {
    
    /// An array of `Recipe` objects decoded from the `recipes` key in the API response.
    let recipes: Recipes
}

