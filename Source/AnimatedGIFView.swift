import SwiftUI
import Cocoa

// MARK: - AppKit Animated GIF NSImageView Container
public class CustomGIFImageView: NSImageView {
    public var currentUrl: URL?
    
    override public init(frame: NSRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.animates = true
        self.imageScaling = .scaleProportionallyUpOrDown
        self.imageAlignment = .alignCenter
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        
        // Prevent NSImageView from expanding based on native image dimensions
        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    override public var intrinsicContentSize: NSSize {
        // Return no intrinsic metric so SwiftUI frame modifiers strictly control sizing
        return NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }
    
    override public func layout() {
        super.layout()
        self.layer?.masksToBounds = true
    }
}

// MARK: - NSViewRepresentable for SwiftUI
public struct NativeGIFPlayer: NSViewRepresentable {
    public let url: URL?
    public let contentMode: NSImageScaling
    
    public init(url: URL?, contentMode: NSImageScaling = .scaleProportionallyUpOrDown) {
        self.url = url
        self.contentMode = contentMode
    }
    
    public func makeNSView(context: Context) -> CustomGIFImageView {
        let imageView = CustomGIFImageView(frame: .zero)
        imageView.imageScaling = contentMode
        return imageView
    }
    
    public func updateNSView(_ nsView: CustomGIFImageView, context: Context) {
        nsView.imageScaling = contentMode
        
        guard let url = url else {
            nsView.image = nil
            nsView.currentUrl = nil
            return
        }
        
        // Avoid redundant reloads
        if nsView.currentUrl == url && nsView.image != nil {
            return
        }
        
        nsView.currentUrl = url
        
        GifService.shared.fetchGifData(url: url) { data in
            guard nsView.currentUrl == url else { return }
            if let data = data, let image = NSImage(data: data) {
                nsView.image = image
            }
        }
    }
}

// MARK: - Full SwiftUI Animated GIF View with Loading & Error States
public struct AnimatedGIFView: View {
    public let urlString: String
    public var placeholderEmoji: String = "🎬"
    public var cornerRadius: CGFloat = 8
    public var contentMode: NSImageScaling = .scaleProportionallyUpOrDown
    
    public init(
        urlString: String,
        placeholderEmoji: String = "🎬",
        cornerRadius: CGFloat = 8,
        contentMode: NSImageScaling = .scaleProportionallyUpOrDown
    ) {
        self.urlString = urlString
        self.placeholderEmoji = placeholderEmoji
        self.cornerRadius = cornerRadius
        self.contentMode = contentMode
    }
    
    public var body: some View {
        ZStack {
            // Background skeleton
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white.opacity(0.06))
            
            if let url = URL(string: urlString) {
                NativeGIFPlayer(url: url, contentMode: contentMode)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .clipped()
            } else {
                VStack(spacing: 2) {
                    Text(placeholderEmoji)
                        .font(.system(size: 20))
                    Text("GIF")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .clipped()
    }
}
