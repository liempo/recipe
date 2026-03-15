//
//  Recipe.swift
//  Recipe
//
//  Created by Alec  on 3/15/26.
//

import Foundation

struct Recipe: Codable, Equatable, Hashable {
  var title: String
  var description: String
  var servings: Int
  var ingredients: [String]
  var instructions: [String]
  var tags: [String]

  enum CodingKeys: String, CodingKey {
    case title
    case description
    case servings
    case ingredients
    case instructions
    case tags
  }

  init(
    title: String = "",
    description: String = "",
    servings: Int = 0,
    ingredients: [String] = [],
    instructions: [String] = [],
    tags: [String] = []
  ) {
    self.title = title
    self.description = description
    self.servings = servings
    self.ingredients = ingredients
    self.instructions = instructions
    self.tags = tags
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
    description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    servings = try container.decodeIfPresent(Int.self, forKey: .servings) ?? 0
    ingredients = try container.decodeIfPresent([String].self, forKey: .ingredients) ?? []
    instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
    tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
  }
}
