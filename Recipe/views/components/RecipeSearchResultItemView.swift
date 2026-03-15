//
//  RecipeSearchResultItemView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SDWebImageSwiftUI
import SwiftUI

struct RecipeSearchResultItemView: View {
  let recipe: Recipe

  private let imageSize: CGFloat = 56

  var body: some View {
    HStack(spacing: 12) {
      recipeImage
      detailsContent
    }
    .padding(.vertical, 4)
  }

  private var recipeImage: some View {
    Group {
      if let urlString = recipe.image, let url = URL(string: urlString) {
        WebImage(url: url) { image in
          image.resizable()
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
    .frame(width: imageSize, height: imageSize)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .id(recipe.id)
  }

  private var imagePlaceholder: some View {
    Rectangle()
      .fill(.gray.opacity(0.4))
      .overlay {
        Image(systemName: "fork.knife")
          .font(.title3)
          .foregroundStyle(.secondary)
      }
  }

  private var detailsContent: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(recipe.title)
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundStyle(.primary)
        .lineLimit(2)

      HStack(spacing: 12) {
        Label("\(recipe.ingredients.count) ingredients", systemImage: "list.bullet")
          .font(.caption)
          .foregroundStyle(.secondary)
        Label(recipe.servings > 0 ? "\(recipe.servings) servings" : "—", systemImage: "person.2")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  List {
    RecipeSearchResultItemView(recipe: Recipe.previews[0])
    RecipeSearchResultItemView(recipe: Recipe.previews[1])
  }
}
