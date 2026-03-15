//
//  Recipe.swift
//  Recipe
//

import Foundation

struct Recipe: Codable, Equatable {
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

}
