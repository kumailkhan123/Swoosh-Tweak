import SwiftUI
import AVFoundation

struct Text_to_Listen: View {
    @State private var textToSpeak = ""
    @State private var isSpeaking = false
    @State private var gearRotation: Double = 0
    @State private var isAnimating = true
    static var synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            // Gear-themed background
            Color(.systemGray6)
                .overlay(
                    GearBackgroundView(rotation: $gearRotation, isAnimating: $isAnimating)
                        .opacity(0.2)
                )
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("Text to Listen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                
                // Main content area
                VStack(spacing: 30) {
                    // Text input
                    TextEditor(text: $textToSpeak)
                        .frame(height: 150)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    
                    // Control buttons
                    HStack(spacing: 30) {
                        // Play/Stop button
                        Button(action: {
                            if isSpeaking {
                                stopSpeaking()
                            } else {
                                speakText(text: textToSpeak)
                            }
                        }) {
                            GearButton(
                                icon: Image(systemName: isSpeaking ? "stop.fill" : "play.fill"),
                                title: isSpeaking ? "Stop" : "Play",
                                color: isSpeaking ? .red : .green
                            )
                        }
                        
                        // Clear button
                        Button(action: {
                            textToSpeak = ""
                        }) {
                            GearButton(
                                icon: Image(systemName: "trash"),
                                title: "Clear",
                                color: .orange
                            )
                        }
                        
                        // Share button
                        Button(action: {
                            shareResult(shareString: textToSpeak)
                        }) {
                            GearButton(
                                icon: Image(systemName: "square.and.arrow.up"),
                                title: "Share",
                                color: .blue
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Start gear rotation animation
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                gearRotation = 360
            }
        }
        .onChange(of: Text_to_Listen.synthesizer.isSpeaking) { isSpeaking in
            if !isSpeaking {
                self.isSpeaking = false
                isAnimating = true
            }
        }
    }
    
    func speakText(text: String) {
        if Text_to_Listen.synthesizer.isSpeaking {
            Text_to_Listen.synthesizer.stopSpeaking(at: .word)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        Text_to_Listen.synthesizer.speak(utterance)
        isSpeaking = true
        isAnimating = false
    }
    
    func stopSpeaking() {
        if Text_to_Listen.synthesizer.isSpeaking {
            Text_to_Listen.synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        isAnimating = true
    }
    
    func shareResult(shareString: String) {
        let activityViewController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
}

struct GearBackgroundView: View {
    @Binding var rotation: Double
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            // Large gear
            GearShape(teeth: 20, toothDepth: 15)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(isAnimating ? rotation : 0))
                .offset(x: -100, y: -100)
            
            // Medium gear
            GearShape(teeth: 12, toothDepth: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(isAnimating ? -rotation * 0.7 : 0))
                .offset(x: 80, y: 50)
            
            // Small gear
            GearShape(teeth: 8, toothDepth: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(isAnimating ? rotation * 0.5 : 0))
                .offset(x: -50, y: 150)
        }
    }
}
// Gear-themed button
struct GearButton: View {
    let icon: Image
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 80)
        .background(
            ZStack {
                Circle()
                    .fill(color)
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            }
        )
        .shadow(radius: 3)
    }
}

// Gear background view
//struct GearBackgroundView: View {
//    @Binding var rotation: Double
//    
//    var body: some View {
//        ZStack {
//            // Large gear
//            GearShape(teeth: 20, toothDepth: 15)
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: 200, height: 200)
//                .rotationEffect(.degrees(rotation))
//                .offset(x: -100, y: -100)
//            
//            // Medium gear
//            GearShape(teeth: 12, toothDepth: 10)
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: 120, height: 120)
//                .rotationEffect(.degrees(-rotation * 0.7))
//                .offset(x: 80, y: 50)
//            
//            // Small gear
//            GearShape(teeth: 8, toothDepth: 8)
//                .fill(Color.gray.opacity(0.3))
//                .frame(width: 80, height: 80)
//                .rotationEffect(.degrees(rotation * 0.5))
//                .offset(x: -50, y: 150)
//        }
//    }
//}



#Preview {
    Text_to_Listen()
}
