//
//  AppDelegate.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftData
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
  var modelContainer: ModelContainer!

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let schema = Schema([
      RecipeEntity.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    do {
      modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
      RecipeRepository.configure(container: modelContainer)
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
    return true
  }
}
