//
//  ContentView.swift
//  FetchTakeHomeAssesment
//
//  Created by Arnav Varyani on 5/29/25.
//

import SwiftUI

struct RecipeView: View {
    @StateObject private var vm = RecipeViewModel()
    @State private var searchText: String = ""
    @Namespace private var animation

    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return vm.recipes
        } else {
            return vm.recipes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.cuisine.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredRecipes) { recipe in
                NavigationLink(value: recipe) {
                    HStack(spacing: 12) {
                        if let path = recipe.localImagePath,
                           let uiImage = UIImage(contentsOfFile: path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(8)
                                .matchedGeometryEffect(id: recipe.id, in: animation)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(ProgressView())
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.name)
                                .font(.headline)
                            Text(recipe.cuisine)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 1), value: recipe.id)
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .refreshable {
                await vm.loadRecipesFromAPI()
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
                    .matchedGeometryEffect(id: recipe.id, in: animation)
            }
            .task {
                await vm.loadRecipesFromAPI()
            }
            .overlay {
                if let msg = vm.errorMessage {
                    Text("Error: \(msg)")
                        .foregroundStyle(.red)
                        .padding()
                } else if vm.recipes.isEmpty {
                    ContentUnavailableView("No Recipes", systemImage: "fork.knife", description: Text("Please check back later or try refreshing."))
                }
            }
        }
    }
}
#Preview {
    RecipeView()
}
