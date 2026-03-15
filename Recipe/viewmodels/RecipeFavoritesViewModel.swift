//
//  RecipeFavoritesViewModel.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Combine
import Foundation

@MainActor
final class RecipeFavoritesViewModel: ObservableObject {

  private let userPreferencesKey = "RecipeFavoritesViewModel.favoriteIds"

  @Published var favoriteIds: Set<Int> = [] {
    didSet { saveToUserPreferences() }
  }

  init() {
    loadFromUserPreferences()
  }

  func toggleFavorite(_ recipe: Recipe) {
    if favoriteIds.contains(recipe.id) {
      favoriteIds.remove(recipe.id)
    } else {
      favoriteIds.insert(recipe.id)
    }
  }

  func isFavorite(_ recipe: Recipe) -> Bool {
    favoriteIds.contains(recipe.id)
  }

  private func loadFromUserPreferences() {
    let array = UserDefaults.standard.array(forKey: userPreferencesKey) as? [Int] ?? []
    favoriteIds = Set(array)
  }

  private func saveToUserPreferences() {
    UserDefaults.standard.set(Array(favoriteIds), forKey: userPreferencesKey)
  }
}
