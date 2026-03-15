//
//  RecipeRowView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SDWebImageSwiftUI
import SwiftUI

struct RecipeCardView: View {
  let recipe: Recipe
  @EnvironmentObject private var favoritesViewModel: RecipeFavoritesViewModel

  private let cardHeight: CGFloat = 200
  private let cornerRadius: CGFloat = 16

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      recipeImage
      gradientOverlay
      cardContent
      favoriteBadge
    }
    .frame(height: cardHeight)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
    .id(recipe.id)
    .frame(maxWidth: .infinity, maxHeight: cardHeight)
    .clipped()
  }

  private var imagePlaceholder: some View {
    Rectangle()
      .fill(.gray.opacity(0.4))
      .overlay {
        Image(systemName: "fork.knife")
          .font(.largeTitle)
          .foregroundStyle(.secondary)
      }
  }

  private var gradientOverlay: some View {
    VStack {
      Spacer()
      LinearGradient(
        colors: [.clear, .black.opacity(0.9)],
        startPoint: .top,
        endPoint: .bottom
      )
    }
    .frame(maxWidth: .infinity, maxHeight: cardHeight)
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
  }

  private var cardContent: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(recipe.title)
        .font(.headline)
        .fontWeight(.bold)
        .foregroundStyle(.white)
        .lineLimit(2)
      HStack(spacing: 16) {
        HStack(spacing: 4) {
          Image(systemName: "list.bullet")
            .font(.caption)
          Text("\(recipe.ingredients.count) ingredients")
            .font(.subheadline)
        }
        .foregroundStyle(.white.opacity(0.9))
        HStack(spacing: 4) {
          Image(systemName: "person.2")
            .font(.caption)
          Text(recipe.servings > 0 ? "\(recipe.servings) servings" : "—")
            .font(.subheadline)
        }
        .foregroundStyle(.white.opacity(0.9))
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 16)
    .padding(.bottom, 16)
  }

  private var favoriteBadge: some View {
    VStack {
      HStack {
        Spacer()
        Button {
          favoritesViewModel.toggleFavorite(recipe)
        } label: {
          Image(systemName: favoritesViewModel.isFavorite(recipe) ? "heart.fill" : "heart")
            .font(.title3)
            .foregroundStyle(favoritesViewModel.isFavorite(recipe) ? .red : .white)
            .shadow(color: .black.opacity(0.5), radius: 2)
        }
        .buttonStyle(.plain)
        .padding(12)
      }
      Spacer()
    }
    .zIndex(1)
  }
}

#Preview {
  let recipe = Recipe.previews.first ??
    Recipe(id: 1, title: "Sample Recipe", servings: 4, ingredients: [Ingredient(name: "A", quantity: 1, unit: ""), Ingredient(name: "B", quantity: 1, unit: "")])
  return VStack {
    RecipeCardView(recipe: recipe)
      .environmentObject(RecipeFavoritesViewModel())
      .padding()
    RecipeCardView(recipe: Recipe(id: 1, title: "Sample Recipe", servings: 4, ingredients: [Ingredient(name: "A", quantity: 1, unit: ""), Ingredient(name: "B", quantity: 1, unit: "")]))
      .environmentObject(RecipeFavoritesViewModel())
      .padding()
  }
}
