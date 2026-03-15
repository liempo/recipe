//
//  RecipeSearchCriteria.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation

/// Parameters for the search endpoint (query and filters).
struct RecipeSearchCriteria: Equatable {
  var instructionQuery: String
  var servings: Int?
  var includeIngredients: [String]
  var excludeIngredients: [String]
  var attributes: [String]

  var hasAnyFilter: Bool {
    let q = instructionQuery.trimmingCharacters(in: .whitespaces)
    let hasServings = (servings ?? 0) > 0
    let include = includeIngredients.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    let exclude = excludeIngredients.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    let attrs = attributes.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    return !q.isEmpty || hasServings || !include.isEmpty || !exclude.isEmpty || !attrs.isEmpty
  }
}
