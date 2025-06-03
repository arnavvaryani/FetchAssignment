//
//  RecipeServiceError.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 6/2/25.
//

import Foundation

/// Defines possible error types that can occur during recipe fetching operations.
enum RecipeServiceError: Error, LocalizedError {
    
    /// Indicates the constructed URL was invalid.
    case invalidURL
    
    /// Represents a network-related error, wrapping a `URLError` instance.
    case network(URLError)
    
    /// Indicates a failure during JSON decoding, wrapping a `DecodingError`.
    case decoding(DecodingError)
    
    /// A catch-all for any other unexpected error.
    case unknown(Error)
    
    /// Provides a user-friendly description of each error case.
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

