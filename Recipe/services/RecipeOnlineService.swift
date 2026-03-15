//
//  RecipeOnlineService.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation

protocol RecipeOnlineServiceProtocol {
  func fetchRecipes() async throws -> [Recipe]
}

final class RecipeOnlineService: RecipeOnlineServiceProtocol {

  func fetchRecipes() async throws -> [Recipe] {
    // TEST: Fetch json from bundle for now, replace with actual API call later
    guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
      throw RecipeOnlineServiceError.missingResource
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode([Recipe].self, from: data)
  }

}

enum RecipeOnlineServiceError: Error {
  case missingResource
}
