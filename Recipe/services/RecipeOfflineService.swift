//
//  RecipeOfflineService.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation
import SwiftData

protocol RecipeOfflineServiceProtocol {
  func getRecipes() async throws -> [Recipe]
  func update(from recipes: [Recipe]) async throws
}

final class RecipeOfflineService: RecipeOfflineServiceProtocol {
  private let container: ModelContainer

  init(container: ModelContainer) {
    self.container = container
  }

  func getRecipes() async throws -> [Recipe] {
    let context = ModelContext(container)
    let descriptor = FetchDescriptor<RecipeEntity>(sortBy: [SortDescriptor(\.title)])
    let entities = try context.fetch(descriptor)
    return entities.map { $0.toRecipe() }
  }

  func update(from recipes: [Recipe]) async throws {
    let context = ModelContext(container)
    let descriptor = FetchDescriptor<RecipeEntity>()
    let existing = try context.fetch(descriptor)
    let existingById = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
    for recipe in recipes {
      if let entity = existingById[recipe.id] {
        entity.update(from: recipe)
      } else {
        context.insert(RecipeEntity(from: recipe))
      }
    }
    try context.save()
  }
}
