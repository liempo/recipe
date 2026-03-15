# Recipe App iOS

A native iOS app built with **Swift** and **SwiftUI** for browsing and searching a collection of cooking recipes. Data is loaded from a bundled JSON file structured like a mock API.

## Setup

1. **Requirements**
   - Xcode 16+ (or compatible with iOS 26 SDK)
   - macOS Sonoma or later
   - Target: iOS 26.2+

2. **Open and run**
   - Clone the repository and open `Recipe.xcodeproj` in Xcode.
   - Select a simulator or device with iOS 26+.
   - Build and run (⌘R). No environment variables or external APIs are required.

3. **Dependencies**
   - The app uses **Swift Package Manager** for [SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI) (recipe images). Xcode will resolve packages on first build.

## Architecture overview

- **Models**  
  `Recipe` and `Ingredient` are Codable domain types. `RecipeEntity` is the SwiftData persistence model. `RecipeSearchCriteria` describes search/filter parameters.

- **Data layer**
  - **RecipeOnlineService**  
    Fetches recipes from the bundled `recipes.json` (mock API). Exposes `getRecipes()` and `searchRecipes(criteria:)` as API calls; search applies filters and returns all matching recipes. Can be swapped for a real network client later.
  - **RecipeOfflineService**  
    Persists and reads recipes via SwiftData for offline/cache use.
  - **RecipeRepository**  
    Single entry point: `getRecipes()` (load from “API” and update cache) and `searchRecipes(criteria:)` (delegates to the online service search API).

- **View models**
  - **RecipeListViewModel**  
    Loads recipes and exposes a `Resource<[Recipe]>` for browse screen and initial load.
  - **RecipeSearchViewModel**  
    Calls the repository's search API with `RecipeSearchCriteria` and exposes `searchResults` (all matching recipes).
  - **RecipeFavoritesViewModel**  
    Manages favorite recipe IDs in UserDefaults (e.g. for heart toggle and favorites screen).

- **UI**
  - **ContentView**  
    Tab bar (Browse, Favorites), injects shared view models via `environmentObject`.
  - **BrowseScreenView**  
    Grid/list of recipe cards, tag filter, navigation to search screen and to recipe detail screen.
  - **SearchScreenView**  
    Search field, filters (servings, include/exclude ingredients, attributes e.g. vegetarian), and full list of matching results.
  - **RecipeDetailView**  
    Full recipe (image, description, ingredients, instructions, tags, favorite).
  - **FavoritesScreenView**  
    List of favorited recipes.

## Key design decisions

- **Repository + services**  
  Data access is behind `RecipeRepository` and protocols (`RecipeOnlineServiceProtocol` and `RecipeOfflineServiceProtocol`), this should easily handle offline caching and future API integration.

- **Search as an API**  
  Search is implemented as `RecipeOnlineService.searchRecipes(criteria:)`, returning all matching `[Recipe]`. The repository delegates to this; no filtering in the repository.

- **Resource type**  
  Async outcomes are represented as `Resource<T>` (idle / loading / success / error), so views can handle loading and errors in one place.

- **SwiftData for cache**  
  Loaded recipes are written to SwiftData so the app could later support offline or cached browsing.

## Assumptions and tradeoffs

- **Mock API**  
  The “API” is a local `recipes.json` in the app bundle. No authentication or real network layer.

- **Search semantics**  
  Instruction/text search is case-insensitive and matches title, description, and instruction steps. Include/exclude ingredients use substring matching on ingredient names. Servings filter is exact match. Attributes (e.g. vegetarian) match recipe tags exactly (after normalizing case).

- **Images**  
  Recipe images are URLs in the JSON; the app uses SDWebImageSwiftUI for loading and caching. 

## Known limitations

- Search does not support full-text ranking or fuzzy matching.
- Recipe's only support up to one image.
