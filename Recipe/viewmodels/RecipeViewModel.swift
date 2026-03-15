//
//  RecipeViewModel.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Combine
import Foundation

@MainActor
final class RecipeViewModel: ObservableObject {
  @Published var recipes: Resource<[Recipe]> = .none

  private let repository: RecipeRepositoryProtocol

  init(repository: RecipeRepositoryProtocol? = nil) {
    self.repository = repository ?? RecipeRepository.shared
  }

  func loadRecipes() async {
    recipes = .loading
    do {
      let list = try await repository.fetchRecipes()
      recipes = .success(list)
    } catch {
      recipes = .error(error)
    }
  }
}
