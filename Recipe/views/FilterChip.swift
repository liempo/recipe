//
//  FilterChip.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftUI

struct FilterChip: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor : Color(.systemFill))
        .foregroundColor(isSelected ? .white : .primary)
        .clipShape(Capsule())
    }
    .buttonStyle(.plain)
  }
}
