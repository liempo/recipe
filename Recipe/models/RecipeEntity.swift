//
//  RecipeEntity.swift
//  Recipe
//

import Foundation
import SwiftData

/// SwiftData-backed entity for offline persistence of recipes.
@Model
final class RecipeEntity {
  var title: String
  var recipeDescription: String
  var numberOfServings: Int

  // SwiftData doesn't persist [String] directly; store as JSON in Data.
  var ingredientsData: Data?
  var instructionsData: Data?
  var dietaryAttributesData: Data?

  var ingredients: [String] {
    get { Self.decodeStringArray(from: ingredientsData) }
    set { ingredientsData = Self.encodeStringArray(newValue) }
  }

  var cookingInstructions: [String] {
    get { Self.decodeStringArray(from: instructionsData) }
    set { instructionsData = Self.encodeStringArray(newValue) }
  }

  var dietaryAttributes: [String] {
    get { Self.decodeStringArray(from: dietaryAttributesData) }
    set { dietaryAttributesData = Self.encodeStringArray(newValue) }
  }

  init(
    title: String = "",
    recipeDescription: String = "",
    numberOfServings: Int = 1,
    ingredients: [String] = [],
    cookingInstructions: [String] = [],
    dietaryAttributes: [String] = []
  ) {
    self.title = title
    self.recipeDescription = recipeDescription
    self.numberOfServings = numberOfServings
    self.ingredientsData = Self.encodeStringArray(ingredients)
    self.instructionsData = Self.encodeStringArray(cookingInstructions)
    self.dietaryAttributesData = Self.encodeStringArray(dietaryAttributes)
  }

  /// Create from a Codable `Recipe` (e.g. from API or import).
  convenience init(from recipe: Recipe) {
    self.init(
      title: recipe.title,
      recipeDescription: recipe.recipeDescription,
      numberOfServings: recipe.numberOfServings,
      ingredients: recipe.ingredients,
      cookingInstructions: recipe.cookingInstructions,
      dietaryAttributes: recipe.dietaryAttributes
    )
  }

  /// Convert to Codable `Recipe` for export or API.
  func toRecipe() -> Recipe {
    Recipe(
      title: title,
      recipeDescription: recipeDescription,
      numberOfServings: numberOfServings,
      ingredients: ingredients,
      cookingInstructions: cookingInstructions,
      dietaryAttributes: dietaryAttributes
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
