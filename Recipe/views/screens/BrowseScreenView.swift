//
//  BrowseScreenView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftUI

struct BrowseScreenView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @EnvironmentObject private var listViewModel: RecipeListViewModel
  @EnvironmentObject private var favoritesViewModel: RecipeFavoritesViewModel
  @State private var selectedBrowseTag: String?

  private let tagRowHeight: CGFloat = 44

  var body: some View {
    NavigationStack {
      Group {
        switch listViewModel.recipes {
        case .idle, .loading:
          ProgressView("Loading recipes…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success:
          browseContent
        case .error(let error):
          ContentUnavailableView(
            "Error", systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription))
        }
      }
      .navigationTitle("Browse")
      .navigationDestination(for: Recipe.self) { recipe in
        RecipeDetailView(recipe: recipe)
      }
    }
  }

  private var browseContent: some View {
    ScrollView {
      VStack(spacing: 0) {
        tagFilterRow

        Group {
          if horizontalSizeClass == .regular {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
              ForEach(browseRecipes, id: \.id) { recipe in
                NavigationLink(value: recipe) {
                  RecipeCardView(recipe: recipe)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
              }
            }
          } else {
            VStack(spacing: 12) {
              ForEach(browseRecipes, id: \.id) { recipe in
                NavigationLink(value: recipe) {
                  RecipeCardView(recipe: recipe)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
              }
            }
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 24)
      }
    }
    .scrollIndicators(.hidden)
    .refreshable {
      await listViewModel.getRecipes()
    }
  }

  private var allTags: [String] {
    guard case .success(let list) = listViewModel.recipes else { return [] }
    return Set(list.flatMap(\.tags)).sorted()
  }

  private var browseRecipes: [Recipe] {
    guard case .success(let list) = listViewModel.recipes else { return [] }
    guard let tag = selectedBrowseTag, !tag.isEmpty else { return list }
    return list.filter { $0.tags.contains(tag) }
  }

  private var tagFilterRow: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        FilterChip(
          title: "All",
          isSelected: selectedBrowseTag == nil
        ) {
          selectedBrowseTag = nil
        }
        ForEach(allTags, id: \.self) { tag in
          FilterChip(
            title: tag,
            isSelected: selectedBrowseTag == tag
          ) {
            selectedBrowseTag = tag
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
    }
    .frame(height: tagRowHeight)
    .background(Color.clear)
  }
}

#Preview {
  let listViewModel = RecipeListViewModel()
  let favoritesViewModel = RecipeFavoritesViewModel()
  listViewModel.recipes = .success(Recipe.previews)
  return BrowseScreenView()
    .environmentObject(listViewModel)
    .environmentObject(favoritesViewModel)
}
