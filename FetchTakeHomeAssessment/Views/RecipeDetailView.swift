//
//  RecipeDetailView.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 6/2/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var showVideo = false
    @State private var showRecipe = false

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Adaptive layout
                    if isLandscape {
                        HStack(alignment: .top, spacing: 16) {
                            recipeImage
                                .frame(width: geometry.size.width * 0.4)
                            
                            recipeDetails
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            recipeImage
                            recipeDetails
                        }
                    }
                }
                .padding()
                .frame(width: geometry.size.width)
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var recipeImage: some View {
        AsyncImage(url: recipe.photoURLLarge ?? recipe.photoURLSmall) { phase in
            switch phase {
            case .empty:
                Color.gray.opacity(0.2)
                    .frame(height: 200)
                    .overlay(ProgressView())
            case .success(let img):
                img
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
            case .failure:
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                .frame(height: 200)
                .cornerRadius(12)
            @unknown default:
                EmptyView()
            }
        }
    }

    private var recipeDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.name)
                .font(.title)
                .fontWeight(.bold)

            Text("Cuisine: \(recipe.cuisine)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                if let source = recipe.sourceURL {
                    Button(action: {
                        showRecipe = true
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("View Source")
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showRecipe) {
                        SafariWebView(url: source)
                    }
                }

                if let youtube = recipe.youtubeURL {
                    Button(action: {
                        showVideo = true
                    }) {
                        HStack {
                            Image(systemName: "play.rectangle.fill")
                            Text("Watch on YouTube")
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showVideo) {
                        SafariWebView(url: youtube)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
