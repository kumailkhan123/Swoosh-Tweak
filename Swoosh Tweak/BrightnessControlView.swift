import SwiftUI

@available(iOS 15.0, *)
@available(iOS 16.0,*)
struct BrightnessControlView: View {
    @State private var brightnessValue: Float = Float(UIScreen.main.brightness * 100)
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isAutoBrightness = false
    @State private var isEditing = false
    
    // Gradient colors based on brightness level (7 colors)
    private var gradientColors: [Color] {
        let brightness = CGFloat(brightnessValue) / 100.0
        
        return [
            Color(hue: 0.58, saturation: 0.8, brightness: brightness * 0.8),
            Color(hue: 0.55, saturation: 0.9, brightness: brightness * 0.85),
            Color(hue: 0.52, saturation: 1.0, brightness: brightness * 0.9),
            Color(hue: 0.5, saturation: 1.0, brightness: brightness), // Main color
            Color(hue: 0.47, saturation: 0.9, brightness: brightness * 0.9),
            Color(hue: 0.45, saturation: 0.8, brightness: brightness * 0.85),
            Color(hue: 0.42, saturation: 0.7, brightness: brightness * 0.8)
        ]
    }
    
    private var foregroundColor: Color {
        brightnessValue > 50 ? .black : .white
    }
    
    var body: some View {
        ZStack {
            // Gradient background that changes with brightness
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut, value: brightnessValue)
            
            List {
                // Header Section
                Section {
                    headerContent
                }
                .listRowBackground(Color.clear)
                
                // Brightness Control Section
                Section(header: Text("BRIGHTNESS SETTINGS").font(.caption)) {
                    autoBrightnessToggle
                    
                    if !isAutoBrightness {
                        brightnessSlider
                    }
                }
                .listRowBackground(Color.white.opacity(0.2))
                
                // Presets Section
                Section(header: Text("QUICK PRESETS").font(.caption)) {
                    brightnessPresets
                }
                .listRowBackground(Color.white.opacity(0.2))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .navigationTitle("Brightness")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                brightnessValue = Float(UIScreen.main.brightness * 100)
            }
            .toast(message: toastMessage, isShowing: $showToast, duration: 1.5)
        }
    }
    
    private var headerContent: some View {
        VStack(alignment: .center, spacing: 12) {
            // Gear shape with dynamic color
            GearShape(teeth: 15, toothDepth: 33)
                .fill(foregroundColor)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(isEditing ? 360 : 0))
                .animation(isEditing ? .linear(duration: 2).repeatForever(autoreverses: false) : .default, value: isEditing)
            
            Text("Display Brightness")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(foregroundColor)
            
            Text("Adjust your screen brightness level")
                .font(.caption)
                .foregroundColor(foregroundColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(EdgeInsets())
        .padding(.vertical, 16)
    }
    
    private var autoBrightnessToggle: some View {
        Toggle(isOn: $isAutoBrightness) {
            Label("Auto Brightness", systemImage: "lightbulb.fill")
                .foregroundColor(foregroundColor)
        }
        .tint(foregroundColor)
        .onChange(of: isAutoBrightness) { newValue in
            toastMessage = newValue ? "Auto brightness enabled" : "Auto brightness disabled"
            showToast = true
        }
    }
    
    private var brightnessSlider: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sun.min")
                    .foregroundColor(foregroundColor)
                Slider(
                    value: $brightnessValue,
                    in: 0...100,
                    step: 5
                ) {
                    Text("Brightness")
                } onEditingChanged: { editing in
                    isEditing = editing
                    if !editing {
                        applyBrightness()
                        toastMessage = "Brightness set to \(Int(brightnessValue))%"
                        showToast = true
                    } else {
                        applyBrightness()
                    }
                }
                .tint(foregroundColor)
                Image(systemName: "sun.max.fill")
                    .foregroundColor(foregroundColor)
            }
            
            HStack {
                Spacer()
                Text("\(Int(brightnessValue))%")
                    .font(.system(.callout, design: .monospaced))
                    .foregroundColor(foregroundColor)
                    .padding(4)
                    .background(foregroundColor.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var brightnessPresets: some View {
        HStack {
            ForEach([25, 50, 75, 100], id: \.self) { level in
                Button(action: {
                    brightnessValue = Float(level)
                    applyBrightness()
                    toastMessage = "Brightness set to \(level)%"
                    showToast = true
                }) {
                    VStack {
                        Image(systemName: brightnessSymbol(for: level))
                            .font(.system(size: 18))
                            .foregroundColor(foregroundColor)
                        Text("\(level)%")
                            .font(.system(size: 12))
                            .foregroundColor(foregroundColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(
                        brightnessValue == Float(level) ?
                        foregroundColor.opacity(0.3) :
                        Color.clear
                    )
                    .cornerRadius(8)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private func applyBrightness() {
        UIScreen.main.brightness = CGFloat(brightnessValue) / 100.0
    }
    
    private func brightnessSymbol(for level: Int) -> String {
        switch level {
        case 0...25: return "moon.fill"
        case 26...50: return "sun.min.fill"
        case 51...75: return "sun.max.fill"
        default: return "sun.max.fill"
        }
    }
}



extension View {
    func toast(message: String, isShowing: Binding<Bool>, duration: Double) -> some View {
        self.modifier(ToastModifier(message: message, isShowing: isShowing, duration: duration))
    }
}

struct ToastModifier: ViewModifier {
    let message: String
    @Binding var isShowing: Bool
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    HStack {
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .shadow(radius: 4)
                    }
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
                .animation(.easeInOut, value: isShowing)
            }
        }
    }
}

@available(iOS 16.0, *)
struct BrightnessControlView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrightnessControlView()
        }
        .preferredColorScheme(.light)
    }
}
