import SwiftUI

struct CategoryBadge: View {
    let category: TaskCategory
    let showLabel: Bool

    init(category: TaskCategory, showLabel: Bool = true) {
        self.category = category
        self.showLabel = showLabel
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.iconName)
                .font(.system(size: 12))

            if showLabel {
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, showLabel ? 8 : 6)
        .padding(.vertical, 4)
        .background(category.color)
        .cornerRadius(6)
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack {
            CategoryBadge(category: .personal)
            CategoryBadge(category: .work)
            CategoryBadge(category: .shopping)
        }
        HStack {
            CategoryBadge(category: .health)
            CategoryBadge(category: .finance)
            CategoryBadge(category: .home)
        }
        HStack {
            CategoryBadge(category: .personal, showLabel: false)
            CategoryBadge(category: .work, showLabel: false)
            CategoryBadge(category: .shopping, showLabel: false)
        }
    }
    .padding()
}
