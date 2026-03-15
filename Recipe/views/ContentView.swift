//
//  ContentView.swift
//  Recipe
//
//  Created by Alec  on 3/15/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  @EnvironmentObject private var viewModel: RecipeViewModel

  var body: some View {
    NavigationSplitView {
      RecipeListView(recipes: viewModel.recipes, viewModel: viewModel)
        .onAppear {
          Task { await viewModel.loadRecipes() }
        }
    } detail: {
      Text("Select a recipe")
    }
  }
}

struct RecipeListView: View {
  let recipes: Resource<[Recipe]>
  let viewModel: RecipeViewModel

  var body: some View {
    Group {
      switch recipes {
      case .none, .loading:
        ProgressView("Loading recipes…")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      case .success(let list):
        List {
          ForEach(Array(list.enumerated()), id: \.offset) { _, recipe in
            NavigationLink(value: recipe) {
              VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                  .font(.headline)
                if !recipe.description.isEmpty {
                  Text(recipe.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                }
              }
            }
          }
        }
      case .error(let error):
        ContentUnavailableView(
          "Error", systemImage: "exclamationmark.triangle",
          description: Text(error.localizedDescription))
      }
    }
    .navigationTitle("Recipes")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Refresh") {
          Task { await viewModel.loadRecipes() }
        }
        .disabled(recipes.isLoading)
      }
    }
    .navigationDestination(for: Recipe.self) { recipe in
      RecipeDetailView(recipe: recipe)
    }
  }
}

extension Resource {
  fileprivate var isLoading: Bool {
    if case .loading = self { return true }
    return false
  }
}

private struct RecipeDetailView: View {
  let recipe: Recipe

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text(recipe.description)
          .font(.body)
        Text("Servings: \(recipe.servings)")
          .font(.subheadline)
        if !recipe.ingredients.isEmpty {
          sectionTitle("Ingredients")
          ForEach(recipe.ingredients, id: \.self) { Text("• \($0)") }
        }
        if !recipe.instructions.isEmpty {
          sectionTitle("Instructions")
          ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
            Text("\(index + 1). \(step)")
          }
        }
        if !recipe.tags.isEmpty {
          sectionTitle("Tags")
          Text(recipe.tags.joined(separator: ", "))
            .font(.subheadline)
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .navigationTitle(recipe.title)
  }

  private func sectionTitle(_ title: String) -> some View {
    Text(title)
      .font(.headline)
      .padding(.top, 8)
  }
}

#Preview {
  let schema = Schema([RecipeEntity.self])
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: schema, configurations: [config])
  RecipeRepository.configure(container: container)
  return ContentView()
    .environmentObject(RecipeViewModel())
}
