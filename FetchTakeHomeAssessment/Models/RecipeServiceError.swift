//
//  RecipeServiceError.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 6/2/25.
//

import Foundation

enum RecipeServiceError: Error, LocalizedError {
    case invalidURL
    case network(URLError)
    case decoding(DecodingError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid endpoint URL."
        case .network(let urlErr):
            return "Network error: \(urlErr.localizedDescription)"
        case .decoding(let decErr):
            return "Decoding error: \(decErr.localizedDescription)"
        case .unknown(let err):
            return "Unexpected error: \(err.localizedDescription)"
        }
    }
}
