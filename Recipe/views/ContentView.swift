//
//  ContentView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  @StateObject private var recipeListViewModel = RecipeListViewModel()
  @StateObject private var favoritesViewModel = RecipeFavoritesViewModel()

  @State private var selectedTab: Tab = .browse



  enum Tab: String, CaseIterable {
    case browse
    case favorites
    case search

    var title: String {
      switch self {
      case .browse: return "Browse"
      case .favorites: return "Favorites"
      case .search: return "Search"
      }
    }

    var systemImage: String {
      switch self {
      case .browse: return "book.fill"
      case .favorites: return "heart.fill"
      case .search: return "magnifyingglass"
      }
    }
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      BrowseScreenView()
        .tabItem { Label(Tab.browse.title, systemImage: Tab.browse.systemImage) }
        .tag(Tab.browse)

      FavoritesScreenView()
        .tabItem { Label(Tab.favorites.title, systemImage: Tab.favorites.systemImage) }
        .tag(Tab.favorites)

      SearchScreenView()
        .tabItem { Label(Tab.search.title, systemImage: Tab.search.systemImage) }
        .tag(Tab.search)
    }
    .environmentObject(recipeListViewModel)
    .environmentObject(favoritesViewModel)
    .onAppear {
      Task { await recipeListViewModel.getRecipes() }
    }
  }
}

#Preview {
  let schema = Schema([RecipeEntity.self])
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: schema, configurations: [config])
  RecipeRepository.configure(container: container)
  return ContentView()
}
