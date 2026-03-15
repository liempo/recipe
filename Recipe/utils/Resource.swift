//
//  Resource.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation

enum Resource<T> {
  case idle
  case loading
  case success(T)
  case error(Error)
}

extension Resource {
  var isLoading: Bool {
    if case .loading = self { return true }
    return false
  }
}
