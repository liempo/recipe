//
//  RecipeOfflineService.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation
import SwiftData

protocol RecipeOfflineServiceProtocol {
  func fetchRecipes() async throws -> [Recipe]
  func replaceAll(with recipes: [Recipe]) async throws
}

/// SwiftData-backed offline storage. Replaces all stored recipes when updated from online.
final class RecipeOfflineService: RecipeOfflineServiceProtocol {
  private let container: ModelContainer

  init(container: ModelContainer) {
    self.container = container
  }

  func fetchRecipes() async throws -> [Recipe] {
    let context = ModelContext(container)
    let descriptor = FetchDescriptor<RecipeEntity>(sortBy: [SortDescriptor(\.title)])
    let entities = try context.fetch(descriptor)
    return entities.map { $0.toRecipe() }
  }

  func replaceAll(with recipes: [Recipe]) async throws {
    let context = ModelContext(container)
    let descriptor = FetchDescriptor<RecipeEntity>()
    let existing = try context.fetch(descriptor)
    for entity in existing {
      context.delete(entity)
    }
    for recipe in recipes {
      context.insert(RecipeEntity(from: recipe))
    }
    try context.save()
  }
}
