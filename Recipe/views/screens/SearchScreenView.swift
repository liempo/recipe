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
  @State private var includeIngredients: [String] = []
  @State private var excludeIngredients: [String] = []
  @State private var attributes: [String] = []

  private static let attributeSuggestions = ["vegan", "halal"]

  private var searchResults: [Recipe] {
    guard case .success(let list) = listViewModel.recipes else { return [] }
    let query = searchInstructionsText.trimmingCharacters(in: .whitespaces)
    let include = includeIngredients.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    let exclude = excludeIngredients.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    let attrs = attributes.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }.filter { !$0.isEmpty }
    let hasServingsFilter = (searchServings ?? 0) > 0
    let hasAnyFilter = !query.isEmpty || hasServingsFilter || !include.isEmpty || !exclude.isEmpty || !attrs.isEmpty
    if !hasAnyFilter {
      return []
    }
    var result = list
    if hasServingsFilter, let servings = searchServings, servings > 0 {
      result = result.filter { $0.servings == servings }
    }
    if !include.isEmpty {
      result = result.filter { recipe in
        include.allSatisfy { ing in
          recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(ing) }
        }
      }
    }
    if !exclude.isEmpty {
      result = result.filter { recipe in
        !exclude.contains { ex in
          recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(ex) }
        }
      }
    }
    if !attrs.isEmpty {
      result = result.filter { recipe in
        attrs.allSatisfy { attr in
          recipe.tags.contains { $0.lowercased() == attr }
        }
      }
    }
    if !query.isEmpty {
      result = result.filter { recipe in
        recipe.title.localizedCaseInsensitiveContains(query)
          || recipe.description.localizedCaseInsensitiveContains(query)
          || recipe.instructions.contains { $0.localizedCaseInsensitiveContains(query) }
      }
    }
    return result
  }

  var body: some View {
    Group {
      switch listViewModel.recipes {
      case .idle, .loading:
        ProgressView("Loading recipes…")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      case .success:
        searchContent
      case .error(let error):
        ContentUnavailableView(
          "Error", systemImage: "exclamationmark.triangle",
          description: Text(error.localizedDescription))
      }
    }
    .navigationTitle("Search")
    .navigationBarTitleDisplayMode(.inline)
  }

  private var searchContent: some View {
    List {
      Section {
        TextField("e.g. chicken curry, bake", text: $searchInstructionsText)
          .textContentType(.none)
          .autocorrectionDisabled()
          .focused($searchFocused)
      } header: {
        Text("Search")
      } footer: {
        Text("Also searches instructions.")
          .font(.footnote)
          .foregroundStyle(.secondary)
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

        VStack(alignment: .leading, spacing: 4) {
          Text("Include ingredients")
            .font(.caption)
            .foregroundStyle(.secondary)
          TagInputView(items: $includeIngredients, placeholder: "Add ingredients to include")
        }

        VStack(alignment: .leading, spacing: 4) {
          Text("Exclude ingredients")
            .font(.caption)
            .foregroundStyle(.secondary)
          TagInputView(items: $excludeIngredients, placeholder: "Add ingredients to exclude")
        }

        VStack(alignment: .leading, spacing: 4) {
          Text("Attributes")
            .font(.caption)
            .foregroundStyle(.secondary)
          TagInputView(
            items: $attributes,
            placeholder: "Add attribute…",
            suggestions: Self.attributeSuggestions
          )
        }
      }

      Section("Results") {
        if searchResults.isEmpty {
          Text("No recipes match the current filters.")
            .foregroundStyle(.secondary)
        } else {
          ForEach(searchResults, id: \.id) { recipe in
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
              RecipeSearchResultItemView(recipe: recipe)
            }
          }
        }
      }
    }
    .listStyle(.insetGrouped)
    .refreshable {
      await listViewModel.getRecipes()
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
