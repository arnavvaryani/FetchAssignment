//
//  RecipeDetailView 2.swift
//  FetchTakeHomeAssessment
//
//  Created by Arnav Varyani on 6/2/25.
//

import SwiftUI

/// A detailed view displaying the full information of a selected `Recipe`.
struct RecipeDetailView: View {
    @State private var vm: RecipeDetailViewModel
    @State private var showVideo = false
    @State private var showRecipe = false
    
    init(recipe: Recipe, cachedImage: UIImage?) {
        self._vm = State(initialValue: RecipeDetailViewModel(
            recipe: recipe,
            cachedSmallImage: cachedImage
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if isLandscape {
                        landscapeLayout(geometry: geometry)
                    } else {
                        portraitLayout
                    }
                }
                .padding()
                .frame(width: geometry.size.width)
            }
        }
        .navigationTitle(vm.recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadLargeImageIfNeeded()
        }
    }
        
    private func landscapeLayout(geometry: GeometryProxy) -> some View {
        HStack(alignment: .top, spacing: 16) {
            recipeImage
                .frame(width: geometry.size.width * 0.4)
            
            recipeDetails
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var portraitLayout: some View {
        VStack(alignment: .leading, spacing: 16) {
            recipeImage
            recipeDetails
        }
    }
    
    
    private var recipeImage: some View {
        RecipeImageView(
            smallImage: vm.smallImage,
            largeImage: vm.largeImage,
            isLoading: vm.showLoadingIndicator
        )
    }
    
    private var recipeDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(vm.recipe.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text("Cuisine: \(vm.recipe.cuisine)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            actionButtons
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            if vm.hasSourceURL {
                sourceButton
            }
            
            if vm.hasYouTubeURL {
                youtubeButton
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var sourceButton: some View {
        Button {
            showRecipe = true
        } label: {
            Label("View Source", systemImage: "link")
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .sheet(isPresented: $showRecipe) {
            if let url = vm.recipe.sourceURL {
                SafariWebView(url: url)
            }
        }
    }
    
    private var youtubeButton: some View {
        Button {
            showVideo = true
        } label: {
            Label("Watch on YouTube", systemImage: "play.rectangle.fill")
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .sheet(isPresented: $showVideo) {
            if let url = vm.recipe.youtubeURL {
                SafariWebView(url: url)
            }
        }
    }
}

/// A reusable component for displaying recipe images with progressive loading
struct RecipeImageView: View {
    let smallImage: UIImage?
    let largeImage: UIImage?
    let isLoading: Bool
    
    var body: some View {
        ZStack {
            if let image = largeImage ?? smallImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
            } else {
                imagePlaceholder
            }
            
            if isLoading {
                loadingOverlay
            }
        }
        .animation(.easeInOut(duration: 0.3), value: largeImage != nil)
    }
    
    private var imagePlaceholder: some View {
        ZStack {
            Color.gray.opacity(0.2)
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 200)
        .cornerRadius(12)
    }
    
    private var loadingOverlay: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(1.2)
            .padding(8)
            .background(Color.black.opacity(0.6))
            .cornerRadius(8)
    }
}
