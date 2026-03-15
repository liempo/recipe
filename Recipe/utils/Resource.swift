//
//  Resource.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import Foundation

enum Resource<T> {
  case none
  case loading
  case success(T)
  case error(Error)
}
