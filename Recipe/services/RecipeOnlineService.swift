//
//  RecipeOnlineService.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation

protocol RecipeOnlineServiceProtocol {
  func getRecipes() async throws -> [Recipe]
  func searchRecipes(criteria: RecipeSearchCriteria) async throws -> [Recipe]
}

final class RecipeOnlineService: RecipeOnlineServiceProtocol {

  func getRecipes() async throws -> [Recipe] {
    guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
      throw RecipeOnlineServiceError.missingResource
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode([Recipe].self, from: data)
  }

  func searchRecipes(criteria: RecipeSearchCriteria) async throws -> [Recipe] {
    let all = try await getRecipes()
    guard criteria.hasAnyFilter else {
      return []
    }
    var filtered = all
    let query = criteria.instructionQuery.trimmingCharacters(in: .whitespaces)
    let include = criteria.includeIngredients.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    let exclude = criteria.excludeIngredients.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    let attrs = criteria.attributes.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }.filter { !$0.isEmpty }

    if let servings = criteria.servings, servings > 0 {
      filtered = filtered.filter { $0.servings == servings }
    }
    if !include.isEmpty {
      filtered = filtered.filter { recipe in
        include.allSatisfy { ing in
          recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(ing) }
        }
      }
    }
    if !exclude.isEmpty {
      filtered = filtered.filter { recipe in
        !exclude.contains { ex in
          recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(ex) }
        }
      }
    }
    if !attrs.isEmpty {
      filtered = filtered.filter { recipe in
        attrs.allSatisfy { attr in
          recipe.tags.contains { $0.lowercased() == attr }
        }
      }
    }
    if !query.isEmpty {
      filtered = filtered.filter { recipe in
        recipe.title.localizedCaseInsensitiveContains(query)
          || recipe.description.localizedCaseInsensitiveContains(query)
          || recipe.instructions.contains { $0.localizedCaseInsensitiveContains(query) }
      }
    }

    return filtered
  }
}

enum RecipeOnlineServiceError: Error {
  case missingResource
}
