//
//  RecipeRepository.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation
import SwiftData

protocol RecipeRepositoryProtocol {
  func getRecipes() async throws -> [Recipe]
}

final class RecipeRepository: RecipeRepositoryProtocol {
  private let online: RecipeOnlineServiceProtocol
  private let offline: RecipeOfflineServiceProtocol

  private static var _shared: RecipeRepository?

  static func configure(container: ModelContainer) {
    guard _shared == nil else { return }
    _shared = RecipeRepository(
      online: RecipeOnlineService(),
      offline: RecipeOfflineService(container: container)
    )
  }

  static var shared: RecipeRepository {
    guard let s = _shared else {
      fatalError(
        "RecipeRepository.configure(container:) must be called before using RecipeRepository.shared"
      )
    }
    return s
  }

  init(online: RecipeOnlineServiceProtocol, offline: RecipeOfflineServiceProtocol) {
    self.online = online
    self.offline = offline
  }

  func getRecipes() async throws -> [Recipe] {
    let list = try await online.getRecipes()
    try await offline.update(from: list)
    return list
  }
}
