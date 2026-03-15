//
//  RecipeApp.swift
//  Recipe
//
//  Created by Alec  on 3/15/26.
//

import SwiftData
import SwiftUI

@main
struct RecipeApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(appDelegate.modelContainer)
  }
}
