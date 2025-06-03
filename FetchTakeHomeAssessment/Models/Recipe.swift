//
//  Recipe.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 5/29/25.
//

import Foundation

/// Represents a single recipe item retrieved from the API.
struct Recipe: Decodable, Identifiable, Hashable {
    
    /// The cuisine category of the recipe (e.g., Italian, Indian).
    let cuisine: String
    
    /// The name/title of the recipe.
    let name: String
    
    /// Optional URL pointing to a high-resolution image of the recipe.
    let photoURLLarge: URL?
    
    /// Optional URL pointing to a low-resolution image of the recipe.
    let photoURLSmall: URL?
    
    /// Optional URL pointing to the source webpage of the recipe.
    let sourceURL: URL?
    
    /// A unique identifier (UUID) for the recipe.
    let uuid: UUID
    
    /// Optional URL pointing to a YouTube video for the recipe.
    let youtubeURL: URL?
    
    /// Conformance to `Identifiable` using `uuid` as the unique identifier.
    var id: UUID { uuid }
    
    /// Maps JSON keys to Swift property names for decoding.
    enum CodingKeys: String, CodingKey {
        case cuisine, name
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case sourceURL = "source_url"
        case uuid
        case youtubeURL = "youtube_url"
    }
}

/// Represents an array of `Recipe` objects.
typealias Recipes = [Recipe]


