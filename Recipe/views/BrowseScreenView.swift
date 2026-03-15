//
//  BrowseScreenView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftUI

struct BrowseScreenView: View {
  @EnvironmentObject private var listViewModel: RecipeListViewModel
  @EnvironmentObject private var favoritesViewModel: RecipeFavoritesViewModel
  @State private var selectedBrowseTag: String?

  var body: some View {
    NavigationStack {
      Group {
        switch listViewModel.recipes {
        case .idle, .loading:
          ProgressView("Loading recipes…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success:
          browseContent
        case .error(let error):
          ContentUnavailableView(
            "Error", systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription))
        }
      }
      .navigationTitle("Browse")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Refresh") {
            Task { await listViewModel.getRecipes() }
          }
          .disabled(listViewModel.recipes.isLoading)
        }
      }
      .navigationDestination(for: Recipe.self) { recipe in
        RecipeDetailView(recipe: recipe)
      }
    }
  }

  private var browseContent: some View {
    VStack(spacing: 0) {
      tagFilter
      recipeList
    }
  }

  private var allTags: [String] {
    guard case .success(let list) = listViewModel.recipes else { return [] }
    return Set(list.flatMap(\.tags)).sorted()
  }

  private var browseRecipes: [Recipe] {
    guard case .success(let list) = listViewModel.recipes else { return [] }
    guard let tag = selectedBrowseTag, !tag.isEmpty else { return list }
    return list.filter { $0.tags.contains(tag) }
  }

  private var tagFilter: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        FilterChip(
          title: "All",
          isSelected: selectedBrowseTag == nil
        ) {
          selectedBrowseTag = nil
        }
        ForEach(allTags, id: \.self) { tag in
          FilterChip(
            title: tag,
            isSelected: selectedBrowseTag == tag
          ) {
            selectedBrowseTag = tag
          }
        }
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
    }
    .background(.bar)
  }

  private var recipeList: some View {
    List {
      ForEach(browseRecipes, id: \.id) { recipe in
        NavigationLink(value: recipe) {
          RecipeRowView(recipe: recipe)
        }
        .swipeActions(edge: .trailing) {
          Button {
            favoritesViewModel.toggleFavorite(recipe)
          } label: {
            Label(
              favoritesViewModel.isFavorite(recipe) ? "Unfavorite" : "Favorite",
              systemImage: favoritesViewModel.isFavorite(recipe) ? "heart.slash" : "heart"
            )
          }
          .tint(.red)
        }
      }
    }
    .listStyle(.plain)
  }
}

#Preview {
  let listViewModel = RecipeListViewModel()
  let favoritesViewModel = RecipeFavoritesViewModel()
  listViewModel.recipes = .success(Recipe.previews)
  return BrowseScreenView()
    .environmentObject(listViewModel)
    .environmentObject(favoritesViewModel)
}
