//
//  Recipe.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 5/29/25.
//


import SwiftUI

struct Recipe: Decodable, Identifiable, Hashable {
    let cuisine: String
    let name: String
    let photoURLLarge: URL?
    let photoURLSmall: URL?
    let sourceURL: URL?
    let uuid: UUID
    let youtubeURL: URL?
    
    var localImagePath: String? = nil
    
    var id: UUID { uuid }
    
    private enum CodingKeys: String, CodingKey {
        case cuisine, name
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case sourceURL = "source_url"
        case uuid
        case youtubeURL = "youtube_url"
    }
}
