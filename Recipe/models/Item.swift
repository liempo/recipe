//
//  Item.swift
//  Recipe
//
//  Created by Alec  on 3/15/26.
//

import Foundation
import SwiftData

@Model
final class Item {
  var timestamp: Date

  init(timestamp: Date) {
    self.timestamp = timestamp
  }
}
