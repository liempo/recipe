//
//  TagInputView.swift
//  Recipe
//
//  Created by Alec on 3/15/26.
//

import SwiftUI

struct TagInputView: View {
  @Binding var items: [String]
  var placeholder: String
  var suggestions: [String] = []

  @State private var newItemText: String = ""
  @FocusState private var isInputFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      if !items.isEmpty {
        FlowLayout(spacing: 8) {
          ForEach(items, id: \.self) { item in
            RemovableChip(title: item) {
              items.removeAll { $0 == item }
            }
          }
        }
      }

      HStack(spacing: 8) {
        TextField(placeholder, text: $newItemText)
          .textContentType(.none)
          .autocorrectionDisabled()
          .onSubmit { addCurrentText() }
          .focused($isInputFocused)

        Button {
          addCurrentText()
        } label: {
          Image(systemName: "plus.circle.fill")
            .font(.title2)
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
      }

      if !suggestions.isEmpty {
        let availableSuggestions = suggestions.filter { s in
          !items.contains(s) && !s.trimmingCharacters(in: .whitespaces).isEmpty
        }
        if !availableSuggestions.isEmpty {
          HStack(alignment: .center, spacing: 6) {
            Text("Suggested")
              .font(.caption2)
              .foregroundStyle(.secondary)
            FlowLayout(spacing: 4) {
              ForEach(availableSuggestions, id: \.self) { suggestion in
                Button {
                  let trimmed = suggestion.trimmingCharacters(in: .whitespaces)
                  if !trimmed.isEmpty && !items.contains(trimmed) {
                    items.append(trimmed)
                  }
                } label: {
                  Text(suggestion)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(.systemFill).opacity(0.7))
                    .foregroundStyle(.secondary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
              }
            }
          }
        }
      }
    }
  }

  private func addCurrentText() {
    let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
    if !trimmed.isEmpty && !items.contains(trimmed) {
      items.append(trimmed)
      newItemText = ""
    }
  }
}

/// A chip that shows a title and removes itself when tapped.
private struct RemovableChip: View {
  let title: String
  let onRemove: () -> Void

  var body: some View {
    Button(action: onRemove) {
      HStack(spacing: 4) {
        Text(title)
          .font(.subheadline.weight(.medium))
        Image(systemName: "xmark.circle.fill")
          .font(.caption)
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(Color(.systemFill))
      .foregroundColor(.primary)
      .clipShape(Capsule())
    }
    .buttonStyle(.plain)
  }
}



#Preview {
  struct PreviewWrapper: View {
    @State private var include: [String] = ["chicken", "garlic"]
    @State private var attributes: [String] = []
    var body: some View {
      List {
        Section("Include ingredients") {
          TagInputView(items: $include, placeholder: "Add ingredient…")
        }
        Section("Attributes") {
          TagInputView(items: $attributes, placeholder: "Add attribute…", suggestions: ["vegan", "halal"])
        }
      }
    }
  }
  return PreviewWrapper()
}
