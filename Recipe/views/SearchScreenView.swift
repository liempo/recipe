//
//  SearchScreenView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftUI

struct SearchScreenView: View {
  @EnvironmentObject private var listViewModel: RecipeListViewModel
  @EnvironmentObject private var favoritesViewModel: RecipeFavoritesViewModel
  @FocusState private var searchFocused: Bool

  @State private var searchInstructionsText: String = ""
  @State private var searchServings: Int?
  @State private var searchVeganOnly: Bool = false
  @State private var includeIngredientsText: String = ""
  @State private var excludeIngredientsText: String = ""

  private var searchResults: [Recipe] {
    guard case .success(let list) = listViewModel.recipes else { return [] }
    var result = list
    if searchVeganOnly {
      result = result.filter { $0.tags.contains("vegan") }
    }
    if let servings = searchServings, servings > 0 {
      result = result.filter { $0.servings == servings }
    }
    let include = includeIngredientsText
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
    if !include.isEmpty {
      result = result.filter { recipe in
        include.allSatisfy { ing in
          recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(ing) }
        }
      }
    }
    let exclude = excludeIngredientsText
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
    if !exclude.isEmpty {
      result = result.filter { recipe in
        !exclude.contains { ex in
          recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(ex) }
        }
      }
    }
    let query = searchInstructionsText.trimmingCharacters(in: .whitespaces)
    if !query.isEmpty {
      result = result.filter { recipe in
        recipe.instructions.contains { $0.localizedCaseInsensitiveContains(query) }
      }
    }
    return result
  }

  var body: some View {
    NavigationStack {
      List {
        Section("Search in instructions") {
          TextField("e.g. boil, bake, fry", text: $searchInstructionsText)
            .textContentType(.none)
            .autocorrectionDisabled()
            .focused($searchFocused)
        }

        Section("Filters") {
          HStack {
            Text("Servings")
            Spacer()
            Picker("Servings", selection: Binding(
              get: { searchServings ?? 0 },
              set: { searchServings = $0 == 0 ? nil : $0 }
            )) {
              Text("Any").tag(0)
              ForEach([1, 2, 4, 6, 8, 10], id: \.self) { n in
                Text("\(n)").tag(n)
              }
            }
            .pickerStyle(.menu)
            .labelsHidden()
          }

          Toggle("Vegan only", isOn: $searchVeganOnly)

          VStack(alignment: .leading, spacing: 4) {
            Text("Include ingredients (comma-separated)")
              .font(.caption)
              .foregroundStyle(.secondary)
            TextField("e.g. chicken, garlic", text: $includeIngredientsText)
              .textContentType(.none)
          }

          VStack(alignment: .leading, spacing: 4) {
            Text("Exclude ingredients (comma-separated)")
              .font(.caption)
              .foregroundStyle(.secondary)
            TextField("e.g. nuts, dairy", text: $excludeIngredientsText)
              .textContentType(.none)
          }
        }

        Section("Results") {
          if searchResults.isEmpty {
            Text("No recipes match the current filters.")
              .foregroundStyle(.secondary)
          } else {
            ForEach(searchResults, id: \.id) { recipe in
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
        }
      }
      .navigationTitle("Search")
      .navigationDestination(for: Recipe.self) { recipe in
        RecipeDetailView(recipe: recipe)
      }
    }
  }
}

#Preview {
  let listViewModel = RecipeListViewModel()
  let favoritesViewModel = RecipeFavoritesViewModel()
  listViewModel.recipes = .success(Recipe.previews)
  return SearchScreenView()
    .environmentObject(listViewModel)
    .environmentObject(favoritesViewModel)
}
