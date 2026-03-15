//
//  RecipeSearchViewModel.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation
import Combine

@MainActor
final class RecipeSearchViewModel: ObservableObject {
  @Published var searchResults: Resource<[Recipe]> = .idle

  private let repository: RecipeRepositoryProtocol

  init(repository: RecipeRepositoryProtocol? = nil) {
    self.repository = repository ?? RecipeRepository.shared
  }

  func search(criteria: RecipeSearchCriteria) async {
    guard criteria.hasAnyFilter else {
      searchResults = .success([])
      return
    }
    searchResults = .loading
    do {
      let recipes = try await repository.searchRecipes(criteria: criteria)
      searchResults = .success(recipes)
    } catch {
      searchResults = .error(error)
    }
  }
}
