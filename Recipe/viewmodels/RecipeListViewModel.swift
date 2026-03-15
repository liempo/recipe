//
//  RecipeListViewModel.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Combine
import Foundation

@MainActor
final class RecipeListViewModel: ObservableObject {
  @Published var recipes: Resource<[Recipe]> = .idle

  private let repository: RecipeRepositoryProtocol

  init(repository: RecipeRepositoryProtocol? = nil) {
    self.repository = repository ?? RecipeRepository.shared
  }

  func getRecipes() async {
    recipes = .loading
    do {
      let list = try await repository.getRecipes()
      recipes = .success(list)
    } catch {
      recipes = .error(error)
    }
  }
}
