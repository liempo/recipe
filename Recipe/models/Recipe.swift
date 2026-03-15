//
//  Recipe.swift
//  Recipe
//
//  Created by Alec  on 3/15/26.
//

import Foundation

struct Ingredient: Codable, Equatable, Hashable {
  var name: String
  var quantity: Double
  var unit: String

  /// e.g. "1 kg vinegar" or "Vinegar" when quantity is 1 and unit is empty.
  var displayString: String {
    let q = quantity
    let u = unit.trimmingCharacters(in: .whitespaces)
    if q == 1 && u.isEmpty { return name }
    if u.isEmpty { return "\(formatQuantity(q)) \(name)" }
    return "\(formatQuantity(q)) \(u) \(name)"
  }

  private func formatQuantity(_ q: Double) -> String {
    if q == floor(q) { return String(Int(q)) }
    return String(q)
  }
}

struct Recipe: Codable, Equatable, Hashable {
  var id: Int
  var title: String
  var description: String
  var servings: Int
  var ingredients: [Ingredient]
  var instructions: [String]
  var tags: [String]
  var image: String?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case description
    case servings
    case ingredients
    case instructions
    case tags
    case image
  }

  init(
    id: Int = 0,
    title: String = "",
    description: String = "",
    servings: Int = 0,
    ingredients: [Ingredient] = [],
    instructions: [String] = [],
    tags: [String] = [],
    image: String? = nil
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.servings = servings
    self.ingredients = ingredients
    self.instructions = instructions
    self.tags = tags
    self.image = image
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
    title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
    description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    servings = try container.decodeIfPresent(Int.self, forKey: .servings) ?? 0
    ingredients = try container.decodeIfPresent([Ingredient].self, forKey: .ingredients) ?? []
    instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
    tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    image = try container.decodeIfPresent(String.self, forKey: .image)
  }
}

#if DEBUG
extension Recipe {
  /// Loads recipes from the bundled recipes.json for previews.
  static var previews: [Recipe] {
    guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let list = try? JSONDecoder().decode([Recipe].self, from: data) else {
      return []
    }
    return list
  }
}
#endif
