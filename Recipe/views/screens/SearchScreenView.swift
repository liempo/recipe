//
//  SearchScreenView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftUI

struct SearchScreenView: View {
  @EnvironmentObject private var searchViewModel: RecipeSearchViewModel
  @EnvironmentObject private var favoritesViewModel: RecipeFavoritesViewModel
  @FocusState private var searchFocused: Bool

  @State private var searchInstructionsText: String = ""
  @State private var searchServings: Int?
  @State private var includeIngredients: [String] = []
  @State private var excludeIngredients: [String] = []
  @State private var attributes: [String] = []

  private static let attributeSuggestions = ["vegetarian", "halal"]

  private var currentCriteria: RecipeSearchCriteria {
    RecipeSearchCriteria(
      instructionQuery: searchInstructionsText,
      servings: searchServings,
      includeIngredients: includeIngredients,
      excludeIngredients: excludeIngredients,
      attributes: attributes
    )
  }

  var body: some View {
    searchContent
      .navigationTitle("Search")
      .navigationBarTitleDisplayMode(.inline)
      .task(id: currentCriteria) {
        await searchViewModel.search(criteria: currentCriteria)
      }
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

      Section(resultsSectionHeader) {
        resultsContent
      }
    }
    .listStyle(.insetGrouped)
    .refreshable {
      await searchViewModel.search(criteria: currentCriteria)
    }
  }

  private var resultsSectionHeader: String {
    switch searchViewModel.searchResults {
    case .success(let list) where !list.isEmpty:
      return "Results (\(list.count))"
    default:
      return "Results"
    }
  }

  @ViewBuilder
  private var resultsContent: some View {
    switch searchViewModel.searchResults {
    case .idle:
      Text(currentCriteria.hasAnyFilter ? "No recipes match the current filters." : "Enter search terms or set filters above.")
        .foregroundStyle(.secondary)
    case .success(let list) where list.isEmpty:
      Text(currentCriteria.hasAnyFilter ? "No recipes match the current filters." : "Enter search terms or set filters above.")
        .foregroundStyle(.secondary)
    case .loading:
      ProgressView("Searching…")
        .frame(maxWidth: .infinity)
    case .success(let list):
      ForEach(list, id: \.id) { recipe in
        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
          RecipeSearchResultItemView(recipe: recipe)
        }
      }
    case .error(let error):
      ContentUnavailableView(
        "Search failed",
        systemImage: "exclamationmark.triangle",
        description: Text(error.localizedDescription)
      )
    }
  }
}

#Preview {
  SearchScreenView()
    .environmentObject(RecipeSearchViewModel())
    .environmentObject(RecipeFavoritesViewModel())
}
