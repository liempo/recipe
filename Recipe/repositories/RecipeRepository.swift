//
//  RecipeRepository.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation
import SwiftData

protocol RecipeRepositoryProtocol {
  func fetchRecipes() async throws -> [Recipe]
}

final class RecipeRepository: RecipeRepositoryProtocol {
  private let online: RecipeOnlineServiceProtocol
  private let offline: RecipeOfflineServiceProtocol

  private static var _shared: RecipeRepository?

  /// The shared repository. Must call `configure(container:)` before first use (e.g. in your App's scene).
  static var shared: RecipeRepository {
    guard let s = _shared else {
      fatalError(
        "RecipeRepository.configure(container:) must be called before using RecipeRepository.shared"
      )
    }
    return s
  }

  /// Configures the singleton with the app's model container. Call once at app startup (AppDelegeate)
  static func configure(container: ModelContainer) {
    guard _shared == nil else { return }
    _shared = RecipeRepository(
      online: RecipeOnlineService(),
      offline: RecipeOfflineService(container: container)
    )
  }

  init(online: RecipeOnlineServiceProtocol, offline: RecipeOfflineServiceProtocol) {
    self.online = online
    self.offline = offline
  }

  func fetchRecipes() async throws -> [Recipe] {
    do {
      let recipes = try await online.fetchRecipes()
      try await offline.replaceAll(with: recipes)
      return recipes
    } catch {
      return try await offline.fetchRecipes()
    }
  }
}
