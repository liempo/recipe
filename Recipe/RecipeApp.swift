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
  @StateObject private var viewModel = RecipeViewModel()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(viewModel)
    }
    .modelContainer(appDelegate.modelContainer)
  }
}
