import Cocoa
import SwiftUI

class FloatingPanel: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 100, y: 100, width: 280, height: 320),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = false
        self.hasShadow = true
        self.isOpaque = false
        self.backgroundColor = .clear
        
        // Setup Visual Effect (Blur background)
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .hudWindow
        visualEffect.autoresizingMask = [.width, .height]
        
        self.contentView = visualEffect
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
    
    func show(at point: CGPoint, content: NSView) {
        // Set content view of visualEffect
        if let visualEffect = self.contentView as? NSVisualEffectView {
            visualEffect.subviews.forEach { $0.removeFromSuperview() }
            content.frame = visualEffect.bounds
            content.autoresizingMask = [.width, .height]
            visualEffect.addSubview(content)
        }
        
        // Position panel at the cursor caret position (centered horizontally above or below caret)
        let size = self.frame.size
        var frame = self.frame
        
        // Position it just below the caret point
        frame.origin.x = point.x - size.width / 2
        frame.origin.y = point.y - size.height - 8
        
        // Make sure it fits on the screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            if frame.origin.x < screenFrame.origin.x {
                frame.origin.x = screenFrame.origin.x + 8
            } else if frame.origin.x + size.width > screenFrame.origin.x + screenFrame.size.width {
                frame.origin.x = screenFrame.origin.x + screenFrame.size.width - size.width - 8
            }
            
            if frame.origin.y < screenFrame.origin.y {
                // If it goes below screen, show it above the caret instead
                frame.origin.y = point.y + 16
            }
        }
        
        self.setFrame(frame, display: true)
        self.makeKeyAndOrderFront(nil)
        self.orderFrontRegardless()
    }
    
    func hidePanel() {
        self.orderOut(nil)
    }
}
