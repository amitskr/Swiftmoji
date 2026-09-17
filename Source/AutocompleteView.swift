import SwiftUI

struct AutocompleteView: View {
    let matches: [EmojiItem]
    let gifMatches: [GifItem]
    let selectedIndex: Int
    let query: String
    let onSelect: (Int) -> Void
    
    var totalCount: Int {
        matches.count + gifMatches.count + 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header showing the active query search
            HStack {
                Text("Matching ")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                + Text(query.isEmpty ? "suggestions" : ":\(query)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.yellow)
                Spacer()
                Text("↵ to select / paste")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 6)
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            // MARK: - 1. Emoji Matches Section
            if !matches.isEmpty {
                VStack(spacing: 2) {
                    ForEach(0..<matches.count, id: \.self) { index in
                        let item = matches[index]
                        let isSelected = index == selectedIndex
                        
                        HStack(spacing: 12) {
                            // Emoji text display
                            Text(item.emoji)
                                .font(.system(size: 22))
                                .frame(width: 30, height: 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(isSelected ? 0.15 : 0.05))
                                )
                            
                            // Shortcode
                            Text(":\(item.shortcode):")
                                .font(.system(size: 12, weight: isSelected ? .medium : .regular, design: .monospaced))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 11))
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect(index)
                        }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.top, 4)
                .padding(.bottom, 4)
            }
            
            // MARK: - 2. GIF Suggestions Section
            if !gifMatches.isEmpty {
                Divider()
                    .background(Color.white.opacity(0.12))
                    .padding(.top, matches.isEmpty ? 0 : 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "video.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.pink.opacity(0.8))
                        Text("GIF SUGGESTIONS")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(0.5)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 4)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<gifMatches.count, id: \.self) { gIndex in
                            let absoluteIndex = matches.count + gIndex
                            let gifItem = gifMatches[gIndex]
                            let isSelected = absoluteIndex == selectedIndex
                            
                            Button(action: {
                                onSelect(absoluteIndex)
                            }) {
                                VStack(spacing: 3) {
                                    ZStack(alignment: .bottomTrailing) {
                                        AnimatedGIFView(
                                            urlString: gifItem.previewUrl,
                                            placeholderEmoji: "🎬",
                                            cornerRadius: 6
                                        )
                                        .frame(width: 84, height: 56)
                                        .clipped()
                                        
                                        Text("GIF")
                                            .font(.system(size: 7, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 3)
                                            .padding(.vertical, 1)
                                            .background(Capsule().fill(Color.black.opacity(0.65)))
                                            .padding(3)
                                    }
                                    .frame(width: 84, height: 56)
                                    .clipped()
                                    
                                    Text(gifItem.title)
                                        .font(.system(size: 9, weight: isSelected ? .bold : .regular))
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                                        .lineLimit(1)
                                        .frame(width: 82)
                                }
                                .padding(4)
                                .frame(width: 90)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isSelected ? Color.pink.opacity(0.25) : Color.white.opacity(0.04))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected ? Color.pink.opacity(0.8) : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
                }
            }
            
            // Empty state if both are empty
            if matches.isEmpty && gifMatches.isEmpty {
                HStack {
                    Spacer()
                    Text("No matching emojis or GIFs")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.vertical, 16)
                    Spacer()
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            // MARK: - 3. "Browse all emoji & GIFs..." item
            let browseIndex = matches.count + gifMatches.count
            let isBrowseSelected = selectedIndex == browseIndex
            
            HStack(spacing: 12) {
                Text("+")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 28, height: 28)
                    .foregroundColor(isBrowseSelected ? .white : .white.opacity(0.6))
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(isBrowseSelected ? 0.15 : 0.05))
                    )
                
                Text("Browse all emojis & GIFs...")
                    .font(.system(size: 12, weight: isBrowseSelected ? .semibold : .regular))
                    .foregroundColor(isBrowseSelected ? .white : .white.opacity(0.85))
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isBrowseSelected ? Color.blue.opacity(0.3) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isBrowseSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect(browseIndex)
            }
            .padding(6)
        }
        .frame(width: 310)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .colorScheme(.dark)
    }
}
