//
//  RecipeDetailView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SDWebImageSwiftUI
import SwiftUI

struct RecipeDetailView: View {
  let recipe: Recipe
  @EnvironmentObject private var favoritesViewModel: RecipeFavoritesViewModel

  var body: some View {
    List {
      Section {
        recipeImage
        if !recipe.description.isEmpty {
          Text(recipe.description)
            .font(.body)
        }
        metrics
        if !recipe.tags.isEmpty {
          tagChips
        }
      }

      Section("Ingredients") {
        ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { _, ingredient in
          LabeledContent {
            Text(quantityString(ingredient))
              .foregroundStyle(.secondary)
          } label: {
            HStack(spacing: 10) {
              Image(systemName: Self.symbolForIngredient(ingredient.name))
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .center)
              Text(ingredient.name)
            }
          }
        }
      }

      if !recipe.instructions.isEmpty {
        Section("Instructions") {
          ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
            HStack(alignment: .top, spacing: 12) {
              Text("\(index + 1)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .center)
              Text(step)
                .font(.body)
            }
          }
        }
      }
    }
    .listStyle(.insetGrouped)
    .navigationTitle(recipe.title)
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        HStack(spacing: 16) {
          Button {
            favoritesViewModel.toggleFavorite(recipe)
          } label: {
            Image(systemName: favoritesViewModel.isFavorite(recipe) ? "heart.fill" : "heart")
              .foregroundStyle(favoritesViewModel.isFavorite(recipe) ? .red : .primary)
          }
        }
      }
    }
  }

  private var recipeImage: some View {
    Group {
      if let urlString = recipe.image, let url = URL(string: urlString) {
        WebImage(url: url) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        } placeholder: {
          imagePlaceholder
        }
        .indicator(.activity)
        .transition(.fade(duration: 0.25))
      } else {
        imagePlaceholder
      }
    }
    .frame(height: 320)
    .frame(maxWidth: .infinity)
    .listRowInsets(EdgeInsets())
    .listRowBackground(Color.clear)
  }

  private var imagePlaceholder: some View {
    Rectangle()
      .fill(.quaternary)
      .overlay {
        Image(systemName: "fork.knife")
          .font(.largeTitle)
          .foregroundStyle(.secondary)
      }
  }

  private var metrics: some View {
    HStack(spacing: 0) {
      metricItem(value: "\(recipe.servings)", unit: "servings")
      metricItem(value: "\(recipe.ingredients.count)", unit: "items")
      metricItem(value: "\(recipe.instructions.count)", unit: "steps")
    }
    .padding(.vertical, 12)
    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
  }

  private func metricItem(value: String, unit: String) -> some View {
    VStack(spacing: 2) {
      Text(value)
        .font(.subheadline.weight(.semibold))
      Text(unit)
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
  }


  private var tagChips: some View {
    WrappingHStack(horizontalSpacing: 8, verticalSpacing: 8) {
      ForEach(recipe.tags, id: \.self) { tag in
        TagChip(title: tag, isSelected: false, action: { })
      }
    }
  }

  private func quantityString(_ ingredient: Ingredient) -> String {
    let q = ingredient.quantity
    let u = ingredient.unit.trimmingCharacters(in: .whitespaces)
    if u.isEmpty { return q == 1 ? "1" : (q == floor(q) ? "\(Int(q))" : "\(q)") }
    return (q == floor(q) ? "\(Int(q))" : "\(q)") + " " + u
  }

  private static func symbolForIngredient(_ name: String) -> String {
    let lower = name.lowercased()
    if lower.contains("egg") { return "oval" }
    if lower.contains("bread") || lower.contains("toast") { return "birthday.cake" }
    if lower.contains("avocado") || lower.contains("tomato") || lower.contains("vegetable") { return "leaf" }
    if lower.contains("cheese") || lower.contains("milk") { return "square.stack.3d.up" }
    if lower.contains("meat") || lower.contains("beef") || lower.contains("chicken") { return "flame" }
    if lower.contains("flour") || lower.contains("sugar") { return "cube" }
    return "leaf"
  }
}

#Preview {
  NavigationStack {
    RecipeDetailView(recipe: Recipe.previews.randomElement() ?? Recipe(
      id: 1,
      title: "Toast with egg and avocado",
      description: "A tasty dish.",
      servings: 2,
      ingredients: [
        Ingredient(name: "Eggs", quantity: 3, unit: "pc"),
        Ingredient(name: "Toast bread", quantity: 2, unit: "pc"),
        Ingredient(name: "Avocado", quantity: 1, unit: "pc")
      ],
      instructions: ["Toast bread", "Boil eggs", "Slice avocado", "Assemble"],
      tags: ["Breakfast", "Fast", "Easy"],
      image: nil
    ))
    .environmentObject(RecipeFavoritesViewModel())
  }
}
