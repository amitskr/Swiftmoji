import SwiftUI
import Cocoa

enum BrowserCategory: String, CaseIterable, Identifiable {
    case emoji = "Emoji"
    case gifs = "GIFs"
    case ascii = "ASCII Emoticons"
    case glyphs = "Glyphs & Symbols"
    case snippets = "Snippets"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .emoji: return "face.smiling.fill"
        case .gifs: return "video.fill"
        case .ascii: return "text.bubble.fill"
        case .glyphs: return "circle.grid.cross.fill"
        case .snippets: return "doc.text.fill"
        }
    }
}

// Data models for placeholders
struct ASCIIItem: Identifiable, Hashable {
    let id = UUID()
    let character: String
    let name: String
}

struct GlyphItem: Identifiable, Hashable {
    let id = UUID()
    let character: String
    let name: String
}

struct SnippetItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let content: String
    let category: String
}

struct GifItem: Identifiable, Hashable {
    let id = UUID()
    let emojiPlaceholder: String
    let title: String
    let urlString: String
}

struct EmojiBrowserView: View {
    @State private var activeCategory: BrowserCategory = .emoji
    @State private var searchQuery: String = ""
    @State private var activeSubcategory: String = "All"
    
    // Selection states for each category
    @State private var selectedEmoji: EmojiItem?
    @State private var selectedASCII: ASCIIItem?
    @State private var selectedGlyph: GlyphItem?
    @State private var selectedSnippet: SnippetItem?
    @State private var selectedGif: GifItem?
    
    // Custom Shortcuts State
    @State private var customShortcuts: [String: [String]] = [:]
    // Usage Statistics State
    @State private var usageStats: [String: Int] = [:]
    
    // Tag editor states
    @State private var isAddingShortcut: Bool = false
    @State private var newShortcutText: String = ""
    @State private var copiedState: Bool = false
    
    // Hover states for sidebar items
    @State private var hoveredCategory: BrowserCategory? = nil
    
    // Subcategories for Emojis
    let subcategories = ["All", "Smileys & People", "Animals & Nature", "Food & Drink", "Travel & Places", "Objects & Symbols"]
    
    // ASCII data
    let asciiItems = [
        ASCIIItem(character: "¯\\_(ツ)_/¯", name: "Shrug"),
        ASCIIItem(character: "(╯°□°）╯︵ ┻━┻", name: "Table Flip"),
        ASCIIItem(character: "┬─┬ノ( º _ º ノ)", name: "Respect Table"),
        ASCIIItem(character: "( ͡° ͜ʖ ͡°)", name: "Lenny Face"),
        ASCIIItem(character: "ಠ_ಠ", name: "Disapproval"),
        ASCIIItem(character: "(づ｡◕‿‿◕｡)づ", name: "Gimme Hug"),
        ASCIIItem(character: "(・_・)", name: "Meh"),
        ASCIIItem(character: "(ಥ﹏ಥ)", name: "Crying"),
        ASCIIItem(character: "(*^▽^*)", name: "Happy Smile"),
        ASCIIItem(character: "(•_•) ( •_•)>⌐■-■ (⌐■_■)", name: "Deal With It"),
        ASCIIItem(character: "༼ つ ◕_◕ ༽つ", name: "Take My Energy"),
        ASCIIItem(character: "(⊙_☉)", name: "Worried"),
        ASCIIItem(character: "ᕙ(⇀‸↼‶)ᕗ", name: "Flexing"),
        ASCIIItem(character: "(^_-)", name: "Wink"),
        ASCIIItem(character: "（╹◡╹）", name: "Cute Smile"),
        ASCIIItem(character: "(=^･^=)", name: "Cat"),
        ASCIIItem(character: "(T_T)", name: "Sad Tear"),
        ASCIIItem(character: "ᕦ(ò_óˇ)ᕤ", name: "Angry Muscle")
    ]
    
    // Glyphs data
    let glyphItems = [
        GlyphItem(character: "⌘", name: "Command"),
        GlyphItem(character: "⌥", name: "Option"),
        GlyphItem(character: "⇧", name: "Shift"),
        GlyphItem(character: "⌃", name: "Control"),
        GlyphItem(character: "⎋", name: "Escape"),
        GlyphItem(character: "⏎", name: "Return"),
        GlyphItem(character: "⌫", name: "Delete"),
        GlyphItem(character: "", name: "Apple Logo"),
        GlyphItem(character: "✦", name: "Sparkle"),
        GlyphItem(character: "★", name: "Star"),
        GlyphItem(character: "▲", name: "Triangle Up"),
        GlyphItem(character: "▼", name: "Triangle Down"),
        GlyphItem(character: "◀", name: "Triangle Left"),
        GlyphItem(character: "▶", name: "Triangle Right"),
        GlyphItem(character: "◆", name: "Diamond"),
        GlyphItem(character: "●", name: "Circle"),
        GlyphItem(character: "■", name: "Square"),
        GlyphItem(character: "✓", name: "Checkmark"),
        GlyphItem(character: "✗", name: "Crossmark"),
        GlyphItem(character: "∞", name: "Infinity"),
        GlyphItem(character: "§", name: "Section"),
        GlyphItem(character: "¶", name: "Paragraph"),
        GlyphItem(character: "†", name: "Dagger"),
        GlyphItem(character: "‡", name: "Double Dagger")
    ]
    
    // Snippets data
    let snippetItems = [
        SnippetItem(title: "Email Signature", content: "Best regards,\nAmit Sarkar\nSoftware Engineer", category: "Personal"),
        SnippetItem(title: "HTML Boilerplate", content: "<!DOCTYPE html>\n<html>\n<head>\n  <title>Document</title>\n</head>\n<body>\n</body>\n</html>", category: "Development"),
        SnippetItem(title: "Lorem Ipsum", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", category: "Text"),
        SnippetItem(title: "Git Commit Template", content: "feat(component): add new feature\n\n- Detailed explanation of changes\n- Breaking changes description\n\nCloses #issue", category: "Development"),
        SnippetItem(title: "Markdown Table", content: "| Header 1 | Header 2 |\n| -------- | -------- |\n| Cell 1   | Cell 2   |", category: "Writing"),
        SnippetItem(title: "SQL Select All", content: "SELECT * FROM table_name WHERE condition ORDER BY created_at DESC;", category: "Development")
    ]
    
    // GIFs placeholder data
    let gifItems = [
        GifItem(emojiPlaceholder: "🎉", title: "Celebration Dance", urlString: "https://giphy.com/..."),
        GifItem(emojiPlaceholder: "🤔", title: "Intense Thinking", urlString: "https://giphy.com/..."),
        GifItem(emojiPlaceholder: "👏", title: "Sarcastic Clapping", urlString: "https://giphy.com/..."),
        GifItem(emojiPlaceholder: "😱", title: "Shocked Face", urlString: "https://giphy.com/..."),
        GifItem(emojiPlaceholder: "👍", title: "Thumbsup Approval", urlString: "https://giphy.com/..."),
        GifItem(emojiPlaceholder: "🥱", title: "Bored Yawn", urlString: "https://giphy.com/...")
    ]
    
    // Base layouts
    var body: some View {
        HStack(spacing: 0) {
            // 1. Left Sidebar
            sidebarView
            
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1)
            
            // 2. Center Content Grid
            centerGridView
            
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1)
            
            // 3. Right Details View
            rightDetailView
        }
        .frame(width: 920, height: 600)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea())
        .colorScheme(.dark)
        .onAppear {
            loadCustomShortcuts()
            loadUsageStats()
            
            // Default selections
            if selectedEmoji == nil {
                selectedEmoji = EmojiDatabase.shared.allEmojis.first
            }
            if selectedASCII == nil {
                selectedASCII = asciiItems.first
            }
            if selectedGlyph == nil {
                selectedGlyph = glyphItems.first
            }
            if selectedSnippet == nil {
                selectedSnippet = snippetItems.first
            }
            if selectedGif == nil {
                selectedGif = gifItems.first
            }
        }
    }
    
    // MARK: - 1. Sidebar View
    private var sidebarView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Window Traffic Lights Spacer
            HStack {
                Spacer()
            }
            .frame(height: 28)
            
            // Header Title
            Text("SWIFTMOJI")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.35))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            
            // Category list
            ForEach(BrowserCategory.allCases) { category in
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        activeCategory = category
                        searchQuery = ""
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 14))
                            .foregroundColor(activeCategory == category ? .blue : .white.opacity(0.6))
                            .frame(width: 20, height: 20)
                        
                        Text(category.rawValue)
                            .font(.system(size: 13, weight: activeCategory == category ? .semibold : .medium))
                            .foregroundColor(activeCategory == category ? .white : .white.opacity(0.8))
                        
                        Spacer()
                        
                        // Active dot
                        if activeCategory == category {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 5, height: 5)
                                .shadow(color: .blue, radius: 4)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(activeCategory == category 
                                  ? Color.blue.opacity(0.15) 
                                  : (hoveredCategory == category ? Color.white.opacity(0.05) : Color.clear))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(activeCategory == category ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 8)
                .onHover { isHovered in
                    if isHovered {
                        hoveredCategory = category
                    } else if hoveredCategory == category {
                        hoveredCategory = nil
                    }
                }
            }
            
            Spacer()
        }
        .frame(width: 190)
        .background(Color.black.opacity(0.15))
    }
    
    // MARK: - 2. Center Grid View
    private var centerGridView: some View {
        VStack(spacing: 0) {
            // Search Header Bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 13))
                    
                    TextField("Search \(activeCategory.rawValue.lowercased())...", text: $searchQuery)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                    
                    if !searchQuery.isEmpty {
                        Button(action: { searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 13))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.06)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Subcategories filter for Emojis
            if activeCategory == .emoji {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(subcategories, id: \.self) { subcat in
                            Button(action: {
                                withAnimation {
                                    activeSubcategory = subcat
                                }
                            }) {
                                Text(subcat)
                                    .font(.system(size: 11, weight: activeSubcategory == subcat ? .semibold : .regular))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(activeSubcategory == subcat ? Color.blue.opacity(0.25) : Color.white.opacity(0.04))
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(activeSubcategory == subcat ? Color.blue.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                                    )
                                    .foregroundColor(activeSubcategory == subcat ? .white : .white.opacity(0.8))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 30)
                .padding(.bottom, 8)
            }
            
            Divider().background(Color.white.opacity(0.08))
            
            // Grid Content
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch activeCategory {
                    case .emoji:
                        emojiGrid
                    case .gifs:
                        gifGrid
                    case .ascii:
                        asciiGrid
                    case .glyphs:
                        glyphsGrid
                    case .snippets:
                        snippetsGrid
                    }
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.05))
    }
    
    // MARK: - Subcategory Grids
    
    // Emoji Grid
    private var emojiGrid: some View {
        let filtered = EmojiDatabase.shared.allEmojis.filter { item in
            // Subcategory filter
            let passSub = activeSubcategory == "All" || item.category == activeSubcategory
            
            // Search filter
            let passSearch = searchQuery.isEmpty || item.shortcode.lowercased().contains(searchQuery.lowercased())
            
            return passSub && passSearch
        }
        
        let columns = [GridItem(.adaptive(minimum: 76, maximum: 90), spacing: 10)]
        
        return Group {
            if filtered.isEmpty {
                emptyGridState(text: "No emojis found matching '\(searchQuery)'")
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filtered) { item in
                        EmojiTileView(emoji: item, isSelected: selectedEmoji?.id == item.id) {
                            selectedEmoji = item
                            isAddingShortcut = false
                            newShortcutText = ""
                        }
                    }
                }
            }
        }
    }
    
    // ASCII Grid
    private var asciiGrid: some View {
        let filtered = asciiItems.filter { item in
            searchQuery.isEmpty || item.name.lowercased().contains(searchQuery.lowercased()) || item.character.contains(searchQuery)
        }
        
        let columns = [GridItem(.adaptive(minimum: 120, maximum: 160), spacing: 10)]
        
        return Group {
            if filtered.isEmpty {
                emptyGridState(text: "No emoticons found")
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filtered) { item in
                        Button(action: {
                            selectedASCII = item
                            isAddingShortcut = false
                            newShortcutText = ""
                        }) {
                            VStack(spacing: 8) {
                                Text(item.character)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.top, 12)
                                    .frame(maxWidth: .infinity)
                                
                                Text(item.name)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.bottom, 12)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedASCII?.id == item.id ? Color.blue.opacity(0.3) : Color.white.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedASCII?.id == item.id ? Color.blue.opacity(0.7) : Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // Glyphs Grid
    private var glyphsGrid: some View {
        let filtered = glyphItems.filter { item in
            searchQuery.isEmpty || item.name.lowercased().contains(searchQuery.lowercased()) || item.character.contains(searchQuery)
        }
        
        let columns = [GridItem(.adaptive(minimum: 76, maximum: 90), spacing: 10)]
        
        return Group {
            if filtered.isEmpty {
                emptyGridState(text: "No symbols found")
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(filtered) { item in
                        Button(action: {
                            selectedGlyph = item
                            isAddingShortcut = false
                            newShortcutText = ""
                        }) {
                            VStack(spacing: 6) {
                                Text(item.character)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.top, 12)
                                
                                Text(item.name)
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.5))
                                    .lineLimit(1)
                                    .padding(.bottom, 12)
                                    .padding(.horizontal, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedGlyph?.id == item.id ? Color.blue.opacity(0.3) : Color.white.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedGlyph?.id == item.id ? Color.blue.opacity(0.7) : Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // Snippets Grid
    private var snippetsGrid: some View {
        let filtered = snippetItems.filter { item in
            searchQuery.isEmpty || item.title.lowercased().contains(searchQuery.lowercased()) || item.content.lowercased().contains(searchQuery.lowercased())
        }
        
        return Group {
            if filtered.isEmpty {
                emptyGridState(text: "No snippets found")
            } else {
                VStack(spacing: 8) {
                    ForEach(filtered) { item in
                        Button(action: {
                            selectedSnippet = item
                            isAddingShortcut = false
                            newShortcutText = ""
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(item.content.replacingOccurrences(of: "\n", with: " "))
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.5))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Text(item.category)
                                    .font(.system(size: 9, weight: .semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.white.opacity(0.06)))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedSnippet?.id == item.id ? Color.blue.opacity(0.25) : Color.white.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedSnippet?.id == item.id ? Color.blue.opacity(0.7) : Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // GIFs Grid
    private var gifGrid: some View {
        let filtered = gifItems.filter { item in
            searchQuery.isEmpty || item.title.lowercased().contains(searchQuery.lowercased())
        }
        
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        
        return Group {
            if filtered.isEmpty {
                emptyGridState(text: "No GIFs found")
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filtered) { item in
                        Button(action: {
                            selectedGif = item
                            isAddingShortcut = false
                            newShortcutText = ""
                        }) {
                            VStack(spacing: 0) {
                                // Graphic Placeholder
                                ZStack {
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.purple.opacity(0.3),
                                            Color.blue.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    
                                    VStack(spacing: 8) {
                                        Text(item.emojiPlaceholder)
                                            .font(.system(size: 40))
                                        
                                        Text("GIF Preview")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                .frame(height: 100)
                                
                                // Label
                                HStack {
                                    Text(item.title)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.04))
                            }
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedGif?.id == item.id ? Color.blue.opacity(0.7) : Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func emptyGridState(text: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.2))
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.4))
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }
    
    // MARK: - 3. Right Detail View
    private var rightDetailView: some View {
        VStack(spacing: 0) {
            switch activeCategory {
            case .emoji:
                if let emoji = selectedEmoji {
                    emojiDetails(emoji)
                } else {
                    emptyDetailState
                }
            case .ascii:
                if let ascii = selectedASCII {
                    asciiDetails(ascii)
                } else {
                    emptyDetailState
                }
            case .glyphs:
                if let glyph = selectedGlyph {
                    glyphDetails(glyph)
                } else {
                    emptyDetailState
                }
            case .snippets:
                if let snippet = selectedSnippet {
                    snippetDetails(snippet)
                } else {
                    emptyDetailState
                }
            case .gifs:
                if let gif = selectedGif {
                    gifDetails(gif)
                } else {
                    emptyDetailState
                }
            }
        }
        .frame(width: 270)
        .background(Color.black.opacity(0.2))
    }
    
    // MARK: - Detail Subviews
    
    // Emoji Details View
    @ViewBuilder
    private func emojiDetails(_ item: EmojiItem) -> some View {
        VStack(spacing: 0) {
            // Visual Preview Box
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 130, height: 130)
                    .overlay(
                        Circle()
                            .stroke(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.15), Color.clear]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 65
                                ),
                                lineWidth: 1.5
                            )
                    )
                
                Text(item.emoji)
                    .font(.system(size: 76))
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .padding(.top, 36)
            .padding(.bottom, 20)
            
            Text(":\(item.shortcode):")
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundColor(.yellow)
                .padding(.bottom, 4)
            
            Text(item.category)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 24)
            
            // Statistics card
            let usage = usageStats[item.emoji] ?? 0
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Usage Statistics")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    Text(usage > 0 ? "Used \(usage) times" : "Never used yet")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.03)))
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            
            // Shortcuts Tag Editor
            tagEditorSection(key: item.emoji, defaultShortcode: item.shortcode)
            
            Spacer()
            
            // Primary Copy Action
            primaryActionButton(textToCopy: item.emoji, incrementKey: item.emoji)
        }
    }
    
    // ASCII Details View
    @ViewBuilder
    private func asciiDetails(_ item: ASCIIItem) -> some View {
        VStack(spacing: 0) {
            // Visual Preview Box
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.03))
                    .frame(height: 110)
                    .padding(.horizontal, 16)
                
                Text(item.character)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 36)
            .padding(.bottom, 20)
            
            Text(item.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.yellow)
                .padding(.bottom, 4)
            
            Text("ASCII Emoticon")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 24)
            
            // Statistics card
            let usage = usageStats[item.character] ?? 0
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Usage Statistics")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    Text(usage > 0 ? "Used \(usage) times" : "Never used yet")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.03)))
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            
            // Shortcuts Tag Editor
            tagEditorSection(key: item.character, defaultShortcode: item.name.lowercased().replacingOccurrences(of: " ", with: "_"))
            
            Spacer()
            
            // Primary Copy Action
            primaryActionButton(textToCopy: item.character, incrementKey: item.character)
        }
    }
    
    // Glyph Details View
    @ViewBuilder
    private func glyphDetails(_ item: GlyphItem) -> some View {
        VStack(spacing: 0) {
            // Visual Preview Box
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 110, height: 110)
                
                Text(item.character)
                    .font(.system(size: 52, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 36)
            .padding(.bottom, 20)
            
            Text(item.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.yellow)
                .padding(.bottom, 4)
            
            Text("Glyph / Special Symbol")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 24)
            
            // Statistics card
            let usage = usageStats[item.character] ?? 0
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Usage Statistics")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    Text(usage > 0 ? "Used \(usage) times" : "Never used yet")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.03)))
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            
            // Shortcuts Tag Editor
            tagEditorSection(key: item.character, defaultShortcode: item.name.lowercased().replacingOccurrences(of: " ", with: "_"))
            
            Spacer()
            
            // Primary Copy Action
            primaryActionButton(textToCopy: item.character, incrementKey: item.character)
        }
    }
    
    // Snippet Details View
    @ViewBuilder
    private func snippetDetails(_ item: SnippetItem) -> some View {
        VStack(spacing: 0) {
            // Visual Preview Box
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(item.title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text("TXT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.blue.opacity(0.15)))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.04))
                
                ScrollView(.vertical) {
                    Text(item.content)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.95))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(height: 120)
            }
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.02)))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.top, 36)
            .padding(.bottom, 20)
            
            Text(item.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.yellow)
                .padding(.bottom, 4)
            
            Text("Snippet / Custom Template")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 16)
            
            // Statistics card
            let usage = usageStats[item.content] ?? 0
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Usage Statistics")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    Text(usage > 0 ? "Used \(usage) times" : "Never used yet")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.03)))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Shortcuts Tag Editor
            tagEditorSection(key: item.content, defaultShortcode: item.title.lowercased().replacingOccurrences(of: " ", with: "_"))
            
            Spacer()
            
            // Primary Copy Action
            primaryActionButton(textToCopy: item.content, incrementKey: item.content)
        }
    }
    
    // GIF Details View
    @ViewBuilder
    private func gifDetails(_ item: GifItem) -> some View {
        VStack(spacing: 0) {
            // Visual Preview Box
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                    .padding(.horizontal, 16)
                
                VStack(spacing: 8) {
                    Text(item.emojiPlaceholder)
                        .font(.system(size: 48))
                    Text("Interactive GIF Panel")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 36)
            .padding(.bottom, 20)
            
            Text(item.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.yellow)
                .padding(.bottom, 4)
            
            Text("GIF / Dynamic Media Placeholder")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 24)
            
            // Explanation
            VStack(alignment: .leading, spacing: 8) {
                Text("ABOUT GIF SUPPORT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                
                Text("Search trending gifs via integrated search API. Copying or selecting a GIF copies its direct CDN link to insert instantly inside rich message fields.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.65))
                    .lineSpacing(3)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.03)))
            .padding(.horizontal, 16)
            
            Spacer()
            
            // Copy URL link directly
            Button(action: {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString("https://media.giphy.com/media/dummy/giphy.gif", forType: .string)
                
                if UserDefaults.standard.bool(forKey: "soundEffects") {
                    NSSound(named: "Pop")?.play()
                }
                
                withAnimation { copiedState = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { copiedState = false }
                }
            }) {
                HStack {
                    Spacer()
                    Image(systemName: copiedState ? "checkmark.circle.fill" : "link")
                        .font(.system(size: 13, weight: .bold))
                    Text(copiedState ? "Link Copied!" : "Copy GIF URL")
                        .font(.system(size: 13, weight: .bold))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(gradient: Gradient(colors: copiedState ? [Color.green, Color.green.opacity(0.8)] : [Color.purple, Color.purple.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Core Shared Helpers for Right Panel
    
    // Unified Tag Editor View
    @ViewBuilder
    private func tagEditorSection(key: String, defaultShortcode: String) -> some View {
        let list = customShortcuts[key] ?? []
        
        VStack(alignment: .leading, spacing: 8) {
            Text("CUSTOM SHORTCODES")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 16)
            
            if list.isEmpty {
                Text("No custom shortcodes. Bind a keyword (e.g. typing :\(defaultShortcode):) to quickly insert this item system-wide.")
                    .font(.system(size: 10.5))
                    .foregroundColor(.white.opacity(0.55))
                    .lineSpacing(2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(list, id: \.self) { code in
                            HStack(spacing: 4) {
                                Text(":\(code):")
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    EmojiDatabase.shared.removeCustomShortcut(for: key, code: code)
                                    loadCustomShortcuts()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.blue.opacity(0.22)))
                            .overlay(Capsule().stroke(Color.blue.opacity(0.45), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            // Inline add controls
            if isAddingShortcut {
                HStack(spacing: 6) {
                    TextField("e.g. \(defaultShortcode)", text: $newShortcutText, onCommit: {
                        addShortcut(for: key)
                    })
                    .font(.system(size: 11, design: .monospaced))
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.08)))
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    
                    Button(action: {
                        addShortcut(for: key)
                    }) {
                        Text("Add")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        isAddingShortcut = false
                        newShortcutText = ""
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 11))
                            .padding(5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
            } else {
                Button(action: {
                    isAddingShortcut = true
                    newShortcutText = ""
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text("Add custom shortcode...")
                            .font(.system(size: 11.5, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // Unified Action Button (Copy & Count increment)
    @ViewBuilder
    private func primaryActionButton(textToCopy: String, incrementKey: String) -> some View {
        Button(action: {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(textToCopy, forType: .string)
            
            // 1. Increment usage stats in UserDefaults
            let usageKey = "emojiUsageCount"
            var dict = UserDefaults.standard.dictionary(forKey: usageKey) as? [String: Int] ?? [:]
            let current = dict[incrementKey] ?? 0
            dict[incrementKey] = current + 1
            UserDefaults.standard.set(dict, forKey: usageKey)
            
            // 2. Refresh local state
            loadUsageStats()
            
            // 3. Play responsive pop sound
            if UserDefaults.standard.bool(forKey: "soundEffects") {
                NSSound(named: "Pop")?.play()
            }
            
            // 4. Copied button visual feedback transition
            withAnimation {
                copiedState = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    copiedState = false
                }
            }
        }) {
            HStack {
                Spacer()
                Image(systemName: copiedState ? "checkmark.circle.fill" : "doc.on.doc.fill")
                    .font(.system(size: 13, weight: .bold))
                Text(copiedState ? "Copied!" : "Copy to Clipboard")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical, 11)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: copiedState ? [Color.green, Color.green.opacity(0.8)] : [Color.blue, Color.blue.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12), lineWidth: 1))
            .shadow(color: copiedState ? Color.green.opacity(0.2) : Color.blue.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
    
    private var emptyDetailState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "face.smiling.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.15))
            
            Text("Select an item to view options")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.35))
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func loadCustomShortcuts() {
        customShortcuts = EmojiDatabase.shared.customShortcuts
    }
    
    private func loadUsageStats() {
        usageStats = UserDefaults.standard.dictionary(forKey: "emojiUsageCount") as? [String: Int] ?? [:]
    }
    
    private func addShortcut(for key: String) {
        let clean = newShortcutText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !clean.isEmpty {
            EmojiDatabase.shared.addCustomShortcut(for: key, code: clean)
            newShortcutText = ""
            isAddingShortcut = false
            loadCustomShortcuts()
        }
    }
}

// MARK: - Supporting Subviews

struct EmojiTileView: View {
    let emoji: EmojiItem
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Text(emoji.emoji)
                    .font(.system(size: 30))
                    .scaleEffect(isHovered ? 1.15 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isHovered)
                
                Text(emoji.shortcode)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.55))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity, minHeight: 74, maxHeight: 82)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.3) : (isHovered ? Color.white.opacity(0.08) : Color.white.opacity(0.03)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue.opacity(0.7) : (isHovered ? Color.white.opacity(0.15) : Color.white.opacity(0.05)), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
