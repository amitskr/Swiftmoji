import SwiftUI

struct AutocompleteView: View {
    let matches: [EmojiItem]
    let selectedIndex: Int
    let query: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header showing the active query search
            HStack {
                Text("Emoji matching ")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                + Text(":\(query)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.yellow)
                Spacer()
                Text("↵ to select")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 6)
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            if !matches.isEmpty {
                ScrollView(.vertical) {
                    VStack(spacing: 2) {
                        ForEach(0..<matches.count, id: \.self) { index in
                            let item = matches[index]
                            let isSelected = index == selectedIndex
                            
                            HStack(spacing: 12) {
                                // Emoji text display
                                Text(item.emoji)
                                    .font(.system(size: 24))
                                    .frame(width: 32, height: 32)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.white.opacity(isSelected ? 0.15 : 0.05))
                                    )
                                
                                // Shortcode
                                Text(":\(item.shortcode):")
                                    .font(.system(size: 13, weight: isSelected ? .medium : .regular, design: .monospaced))
                                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 12))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 260)
                
                Divider()
                    .background(Color.white.opacity(0.15))
            } else {
                // Show a helpful empty state
                HStack {
                    Spacer()
                    Text("No matching emojis")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.vertical, 16)
                    Spacer()
                }
                
                Divider()
                    .background(Color.white.opacity(0.15))
            }
            
            // "Browse all emoji..." item
            let isBrowseSelected = selectedIndex == matches.count
            HStack(spacing: 12) {
                Text("+")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 32, height: 32)
                    .foregroundColor(isBrowseSelected ? .white : .white.opacity(0.6))
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(isBrowseSelected ? 0.15 : 0.05))
                    )
                
                Text("Browse all emoji...")
                    .font(.system(size: 13, weight: isBrowseSelected ? .semibold : .regular))
                    .foregroundColor(isBrowseSelected ? .white : .white.opacity(0.8))
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isBrowseSelected ? Color.blue.opacity(0.3) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isBrowseSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .padding(6)
        }
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .colorScheme(.dark) // Force dark mode for HUD panel feel
    }
}
