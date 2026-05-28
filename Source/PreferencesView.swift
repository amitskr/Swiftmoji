import SwiftUI
import ServiceManagement

struct PreferencesView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("triggerCharacter") private var triggerCharacter = ":"
    @AppStorage("useDoubleTrigger") private var useDoubleTrigger = false
    @AppStorage("soundEffects") private var soundEffects = true
    @AppStorage("skinTone") private var skinTone = 0
    
    let skinTones = ["👋", "👋🏻", "👋🏼", "👋🏽", "👋🏾", "👋🏿"]
    let triggerOptions = [":", ";", ".", ",", "~"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title Header
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16))
                Text("Preferences")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 5)
            
            VStack(spacing: 0) {
                // Row 1: Launch at Login
                preferenceRow(
                    title: "Launch at login",
                    description: "Start Swiftmoji automatically when you log in",
                    control: Toggle("", isOn: $launchAtLogin)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .labelsHidden()
                        .onChange(of: launchAtLogin) { newValue in
                            setLaunchAtLogin(newValue)
                        }
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                // Row 2: Trigger key (Matches user's layout specification)
                preferenceRow(
                    title: "Trigger key",
                    description: "Character and method that activates emoji lookup",
                    control: HStack(spacing: 8) {
                        Menu {
                            ForEach(triggerOptions, id: \.self) { char in
                                Button(char) {
                                    triggerCharacter = char
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(triggerCharacter)
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.1)))
                            .foregroundColor(.white)
                        }
                        .menuStyle(.borderlessButton)
                        
                        // Tooltip help icon
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.white.opacity(0.3))
                            .font(.system(size: 16))
                            .help("Select the character used to search for emojis. Checking 'Use double key trigger' requires typing this character twice consecutively to open autocomplete.")
                        
                        // Checkbox toggle
                        Toggle("Use double key trigger", isOn: $useDoubleTrigger)
                            .toggleStyle(.checkbox)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                // Row 3: Sound effects
                preferenceRow(
                    title: "Sound effects",
                    description: "Play a soft pop when inserting emoji",
                    control: Toggle("", isOn: $soundEffects)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .labelsHidden()
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                // Row 4: Skin tone
                preferenceRow(
                    title: "Skin tone",
                    description: "Default skin modifier for supported emoji",
                    control: HStack(spacing: 6) {
                        ForEach(0..<skinTones.count, id: \.self) { index in
                            Button(action: {
                                skinTone = index
                            }) {
                                Text(skinTones[index])
                                    .font(.system(size: 18))
                                    .padding(4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(skinTone == index ? Color.blue.opacity(0.3) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(skinTone == index ? Color.blue : Color.clear, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                // Row 5: Global shortcut
                preferenceRow(
                    title: "Global shortcut",
                    description: "Open full emoji picker instantly",
                    control: HStack(spacing: 4) {
                        shortcutKeyLabel(text: "⌘")
                        shortcutKeyLabel(text: "^")
                        shortcutKeyLabel(text: "Space")
                    }
                )
            }
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.12, green: 0.12, blue: 0.14).opacity(0.6)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .padding(20)
        .frame(width: 500, height: 400) // Slightly widened to fit the trigger options cleanly
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea())
        .colorScheme(.dark)
    }
    
    @ViewBuilder
    private func preferenceRow<Content: View>(title: String, description: String, control: Content) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            control
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private func shortcutKeyLabel(text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.15), lineWidth: 1))
            .foregroundColor(.white.opacity(0.8))
    }
    
    private func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            if enabled {
                try? service.register()
            } else {
                try? service.unregister()
            }
        } else {
            // Fallback for macOS 11 & 12
            SMLoginItemSetEnabled("com.antigravity.Swiftmoji" as CFString, enabled)
        }
    }
}

// SwiftUI wrapper for visual blur HUD backdrop
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
