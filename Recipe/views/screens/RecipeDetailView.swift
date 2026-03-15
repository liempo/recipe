//
//  RecipeDetailView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftUI

struct RecipeDetailView: View {
  let recipe: Recipe
  @EnvironmentObject private var favoritesViewModel: RecipeFavoritesViewModel

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text(recipe.description)
            .font(.body)
          Spacer()
          Button {
            favoritesViewModel.toggleFavorite(recipe)
          } label: {
            Image(systemName: favoritesViewModel.isFavorite(recipe) ? "heart.fill" : "heart")
              .font(.title2)
              .foregroundStyle(favoritesViewModel.isFavorite(recipe) ? .red : .secondary)
          }
        }
        Text("Servings: \(recipe.servings)")
          .font(.subheadline)
        if !recipe.ingredients.isEmpty {
          sectionTitle("Ingredients")
          ForEach(recipe.ingredients, id: \.self) { ingredient in
            Text("• \(ingredient.displayString)")
          }
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
  let recipe = Recipe.previews.first ?? Recipe(title: "Sample Recipe", description: "A tasty dish.", servings: 4, ingredients: [Ingredient(name: "Flour", quantity: 100, unit: "g"), Ingredient(name: "Eggs", quantity: 2, unit: "")], instructions: ["Mix", "Bake"])
  return NavigationStack {
    RecipeDetailView(recipe: recipe)
      .environmentObject(RecipeFavoritesViewModel())
  }
}
