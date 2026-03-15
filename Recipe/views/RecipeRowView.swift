//
//  RecipeRowView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftUI

struct RecipeRowView: View {
  let recipe: Recipe
  @EnvironmentObject private var favoritesViewModel: RecipeFavoritesViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(recipe.title)
          .font(.headline)
        Spacer()
        if favoritesViewModel.isFavorite(recipe) {
          Image(systemName: "heart.fill")
            .foregroundStyle(.red)
            .font(.caption)
        }
      }
      if !recipe.description.isEmpty {
        Text(recipe.description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
      }
    }
    .padding(.vertical, 2)
  }
}
