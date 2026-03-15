//
//  RecipeEntity.swift
//  Recipe
//
//  Created by Alec  on 3/15/26.
//

import Foundation
import SwiftData

/// SwiftData-backed entity for offline persistence of recipes.
@Model
final class RecipeEntity {
  var title: String
  var recipeDescription: String // `description` is reserved in Model
  var servings: Int

  // SwiftData doesn't persist [String] directly; store as JSON in Data.
  var ingredientsData: Data?
  var instructionsData: Data?
  var tagsData: Data?

  var ingredients: [String] {
    get { Self.decodeStringArray(from: ingredientsData) }
    set { ingredientsData = Self.encodeStringArray(newValue) }
  }

  var instructions: [String] {
    get { Self.decodeStringArray(from: instructionsData) }
    set { instructionsData = Self.encodeStringArray(newValue) }
  }

  var tags: [String] {
    get { Self.decodeStringArray(from: tagsData) }
    set { tagsData = Self.encodeStringArray(newValue) }
  }

  init(
    title: String = "",
    description: String = "",
    servings: Int = 0,
    ingredients: [String] = [],
    instructions: [String] = [],
    tags: [String] = []
  ) {
    self.title = title
    self.recipeDescription = description
    self.servings = servings
    self.ingredientsData = Self.encodeStringArray(ingredients)
    self.instructionsData = Self.encodeStringArray(instructions)
    self.tagsData = Self.encodeStringArray(tags)
  }

  /// Create from a Codable `Recipe` (e.g. from API or import).
  convenience init(from recipe: Recipe) {
    self.init(
      title: recipe.title,
      description: recipe.description,
      servings: recipe.servings,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      tags: recipe.tags
    )
  }

  /// Convert to Codable `Recipe` for export or API.
  func toRecipe() -> Recipe {
    Recipe(
      title: title,
      description: recipeDescription,
      servings: servings,
      ingredients: ingredients,
      instructions: instructions,
      tags: tags
    )
  }

  private static func encodeStringArray(_ array: [String]) -> Data? {
    try? JSONEncoder().encode(array)
  }

  private static func decodeStringArray(from data: Data?) -> [String] {
    guard let data else { return [] }
    return (try? JSONDecoder().decode([String].self, from: data)) ?? []
  }
}
