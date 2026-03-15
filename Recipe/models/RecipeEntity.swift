//
//  RecipeEntity.swift
//  Recipe
//
//  Created by Alec  on 3/15/26.
//

import Foundation
import SwiftData

@Model
final class RecipeEntity {
  var id: Int
  var title: String
  var recipeDescription: String
  var servings: Int
  var image: String?

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
    id: Int = -1,
    title: String = "",
    description: String = "",
    servings: Int = 0,
    ingredients: [String] = [],
    instructions: [String] = [],
    tags: [String] = [],
    image: String? = nil
  ) {
    self.id = id
    self.title = title
    self.recipeDescription = description
    self.servings = servings
    self.image = image
    self.ingredientsData = Self.encodeStringArray(ingredients)
    self.instructionsData = Self.encodeStringArray(instructions)
    self.tagsData = Self.encodeStringArray(tags)
  }

  convenience init(from recipe: Recipe) {
    self.init(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      servings: recipe.servings,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      tags: recipe.tags,
      image: recipe.image
    )
  }

  func toRecipe() -> Recipe {
    Recipe(
      id: id,
      title: title,
      description: recipeDescription,
      servings: servings,
      ingredients: ingredients,
      instructions: instructions,
      tags: tags,
      image: image
    )
  }

  func update(from recipe: Recipe) {
    guard id == recipe.id else {
      fatalError("RecipeEntity.update(from:) called with mismatched id: \(id) != \(recipe.id)") 
    }
    title = recipe.title
    recipeDescription = recipe.description
    servings = recipe.servings
    image = recipe.image
    ingredients = recipe.ingredients
    instructions = recipe.instructions
    tags = recipe.tags
  }

  private static func encodeStringArray(_ array: [String]) -> Data? {
    try? JSONEncoder().encode(array)
  }

  private static func decodeStringArray(from data: Data?) -> [String] {
    guard let data else { return [] }
    return (try? JSONDecoder().decode([String].self, from: data)) ?? []
  }
}
