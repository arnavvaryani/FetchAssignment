//
//  ContentView.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 5/29/25.
//

import SwiftUI

/// Displays a searchable, sortable list of recipes with image previews and navigation to detail views.
struct RecipeView: View {
    /// View model responsible for all business logic and data management
    @State private var vm = RecipeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if vm.hasError {
                    errorView
                } else if vm.isEmpty {
                    emptyView
                } else {
                    recipeList
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .task {
                await vm.loadRecipesFromAPI()
            }
            .toolbar {
                toolbarContent
            }
        }
    }
        
    private var recipeList: some View {
        List(vm.filteredAndSortedRecipes) { recipe in
            NavigationLink(value: recipe) {
                RecipeRowView(
                    recipe: recipe,
                    image: vm.image(for: recipe.uuid)
                )
            }
        }
        .refreshable {
            await vm.refreshRecipes()
        }
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(
                recipe: recipe,
                cachedImage: vm.image(for: recipe.uuid)
            )
        }
    }
    
    private var errorView: some View {
        ContentUnavailableView(
            "Something went wrong",
            systemImage: "exclamationmark.triangle",
            description: Text(vm.errorMessage ?? "Unknown error")
        )
    }
    
    private var emptyView: some View {
        ContentUnavailableView(
            "No Recipes",
            systemImage: "fork.knife",
            description: Text("Please try refreshing.")
        )
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Task { await vm.refreshRecipes() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .help("Refresh Recipes")
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                ForEach(RecipeViewModel.SortOption.allCases) { option in
                    Button {
                        vm.sortOption = option
                    } label: {
                        Label(
                            option.rawValue,
                            systemImage: option == vm.sortOption ? "checkmark" : ""
                        )
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
            .help("Sort Recipes")
        }
    }
}

/// A reusable row component for displaying a recipe in the list
struct RecipeRowView: View {
    let recipe: Recipe
    let image: UIImage?
    
    var body: some View {
        HStack(spacing: 12) {
            recipeImage
            recipeInfo
        }
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: 0.3), value: image != nil)
    }
    
    private var recipeImage: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(ProgressView().scaleEffect(0.5))
            }
        }
        .frame(width: 60, height: 60)
        .clipped()
        .cornerRadius(8)
    }
    
    private var recipeInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.name)
                .font(.headline)
                .lineLimit(2)
            
            Text(recipe.cuisine)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RecipeView()
}

