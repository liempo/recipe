//
//  FavoritesScreenView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftUI

struct FavoritesScreenView: View {
  @EnvironmentObject private var listViewModel: RecipeListViewModel
  @EnvironmentObject private var favoritesViewModel: RecipeFavoritesViewModel

  private var favoriteRecipes: [Recipe] {
    guard case .success(let list) = listViewModel.recipes else { return [] }
    return list.filter { favoritesViewModel.favoriteIds.contains($0.id) }
  }

  var body: some View {
    NavigationStack {
      Group {
        if case .success = listViewModel.recipes {
          if favoriteRecipes.isEmpty {
            ContentUnavailableView(
              "No Favorites",
              systemImage: "heart.slash",
              description: Text("Tap the heart on a recipe in Browse to add it here.")
            )
          } else {
            List {
              ForEach(favoriteRecipes, id: \.id) { recipe in
                NavigationLink(value: recipe) {
                  RecipeRowView(recipe: recipe)
                }
                .swipeActions(edge: .trailing) {
                  Button(role: .destructive) {
                    favoritesViewModel.toggleFavorite(recipe)
                  } label: {
                    Label("Remove", systemImage: "heart.slash")
                  }
                }
              }
            }
            .listStyle(.plain)
          }
        } else if case .loading = listViewModel.recipes {
          ProgressView("Loading…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          ContentUnavailableView(
            "Load recipes",
            systemImage: "arrow.clockwise",
            description: Text("Open Browse to load recipes.")
          )
        }
      }
      .navigationTitle("Favorites")
      .navigationDestination(for: Recipe.self) { recipe in
        RecipeDetailView(recipe: recipe)
      }
    }
  }
}

#Preview("With favorites") {
  let listViewModel = RecipeListViewModel()
  let favoritesViewModel = RecipeFavoritesViewModel()
  listViewModel.recipes = .success(Recipe.previews)
  if let first = Recipe.previews.first {
    favoritesViewModel.favoriteIds = [first.id]
  }
  return FavoritesScreenView()
    .environmentObject(listViewModel)
    .environmentObject(favoritesViewModel)
}

#Preview("Empty") {
  let listViewModel = RecipeListViewModel()
  let favoritesViewModel = RecipeFavoritesViewModel()
  listViewModel.recipes = .success(Recipe.previews)
  return FavoritesScreenView()
    .environmentObject(listViewModel)
    .environmentObject(favoritesViewModel)
}
