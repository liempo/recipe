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
        switch listViewModel.recipes {
        case .idle, .loading:
          ProgressView("Loading…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success:
          if favoriteRecipes.isEmpty {
            ContentUnavailableView(
              "No Favorites",
              systemImage: "heart.slash",
              description: Text("Tap the heart on a recipe in Browse to add it here.")
            )
          } else {
            favoritesContent
          }
        case .error:
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

  private var favoritesContent: some View {
    ScrollView {
      VStack(spacing: 12) {
        ForEach(favoriteRecipes, id: \.id) { recipe in
          NavigationLink(value: recipe) {
            RecipeCardView(recipe: recipe)
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 8)
      .padding(.bottom, 24)
    }
    .scrollIndicators(.hidden)
    .refreshable {
      await listViewModel.getRecipes()
    }
  }
}

#Preview {
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
