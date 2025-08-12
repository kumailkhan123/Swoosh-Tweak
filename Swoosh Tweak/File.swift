
import SwiftUI



struct PixelBlock: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let blockSize = min(rect.width, rect.height) / 4
        for y in 0...3 {
            for x in 0...3 {
                let origin = CGPoint(x: CGFloat(x) * blockSize, y: CGFloat(y) * blockSize)
                path.addRect(CGRect(origin: origin, size: CGSize(width: blockSize, height: blockSize)))
            }
        }
        return path
    }
}


struct GridFrame: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let gridSize = min(rect.width, rect.height) / 8
        for y in 0...7 {
            for x in 0...7 {
                let origin = CGPoint(x: CGFloat(x) * gridSize, y: CGFloat(y) * gridSize)
                path.addRect(CGRect(origin: origin, size: CGSize(width: gridSize, height: gridSize)))
            }
        }
        path.addRect(rect)
        return path
    }
}


struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let sides = 6
        let angle = 2 * .pi / CGFloat(sides)
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for i in 0..<sides {
            let x = center.x + radius * cos(CGFloat(i) * angle)
            let y = center.y + radius * sin(CGFloat(i) * angle)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Smooth Wave Shape
struct WavePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midHeight = rect.height / 2
        let width = rect.width

        path.move(to: CGPoint(x: 0, y: midHeight))
        for x in stride(from: 0, through: width, by: 10) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4)
            let y = midHeight + sine * 20
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}




// MARK: - BlockButton
struct BlockButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var scaleEffect: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.2)) {
                scaleEffect = 0.95
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2)) {
                    scaleEffect = 1.0
                }
            }
        }) {
            ZStack {
                PixelBlock()
                    .fill(color.opacity(0.85))
                    .frame(width: 70, height: 70)
                PixelBlock()
                    .stroke(PxSkchDesignTokens.Colors.fadeGray, lineWidth: 15)
                    .frame(width: 70, height: 70)
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color.white)
                    Text(title)
                        .font(PxSkchDesignTokens.Typography.caption)
                        .foregroundColor(Color.white)
                }
            }
        }
        .scaleEffect(scaleEffect)
    }
}

// MARK: - LargeBlockButton
struct LargeBlockButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            PixelBlock()
                .fill(color.opacity(0.85))
                .frame(width: 180, height: 180)
            PixelBlock()
                .stroke(PxSkchDesignTokens.Colors.fadeGray, lineWidth: 3)
                .frame(width: 180, height: 180)
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(PxSkchDesignTokens.Colors.neonYellow)
                Text(title)
                    .font(PxSkchDesignTokens.Typography.title)
                    .foregroundColor(PxSkchDesignTokens.Colors.neonYellow)
            }
        }
    }
}

// MARK: - CustomModalView
struct CustomModalView: View {
    let title: String
    let message: String
    let dismissAction: () -> Void
    
    var body: some View {
        ZStack {
            PxSkchDesignTokens.Colors.darkGrid.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 15) {
                Text(title)
                    .font(PxSkchDesignTokens.Typography.title)
                    .foregroundColor(PxSkchDesignTokens.Colors.neonYellow)
                Text(message)
                    .font(PxSkchDesignTokens.Typography.body)
                    .foregroundColor(PxSkchDesignTokens.Colors.neonYellow)
                    .multilineTextAlignment(.center)
                BlockButton(
                    title: "OK",
                    icon: "checkmark",
                    color: PxSkchDesignTokens.Colors.retroRed,
                    action: dismissAction
                )
            }
            .padding(20)
            .frame(width: 280)
            .background(
                PixelBlock()
                    .fill(PxSkchDesignTokens.Colors.pixelBlue.opacity(0.9))
            )
            .overlay(
                PixelBlock()
                    .stroke(PxSkchDesignTokens.Colors.fadeGray, lineWidth: 2)
            )
        }
    }
}




@available(iOS 16.0, *)
struct GlassPanel<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 4)

            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

import SwiftUI
import MediaPlayer



// MARK: - Holographic Button Style

@available(iOS 16.0, *)
struct HoloButton: View {
    var text: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.7), lineWidth: 2)
                        .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 0)
                )
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.02))
        )
    }
}


// MARK: - Retro Terminal Button

@available(iOS 16.0, *)
struct TerminalButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.green.opacity(0.8), lineWidth: 1.5)
                )
                .background(Color.black)
        }
        .padding(.horizontal)
    }
}


// MARK: - Holographic Image Display

@available(iOS 16.0, *)
struct HologramImage: View {
    var image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
            )
            .shadow(color: .cyan.opacity(0.6), radius: 10)
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .padding(.horizontal)
    }
}


// MARK: - Holographic Blurred Background

@available(iOS 16.0, *)
struct HolographicBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .indigo, .blue.opacity(0.3)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            Circle()
                .fill(.blue.opacity(0.2))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(x: -150, y: -200)
            Circle()
                .fill(.purple.opacity(0.2))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 180, y: 250)
        }
    }
}


// MARK: - Glowing Grid Background
struct GridBackground: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ForEach(0..<20, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
                    .offset(y: CGFloat(index * 40) - 400)
            }
            ForEach(0..<10, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 1)
                    .offset(x: CGFloat(index * 40) - 200)
            }
        }
    }
}

// MARK: - Arcade Button
struct ExportActionButton: View {
    var title: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Pixellari", size: 18))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(color.opacity(0.3))
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(color, lineWidth: 2)
                            .shadow(color: color.opacity(0.7), radius: 8)
                    }
                )
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
}




struct HologramCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1.5)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .blur(radius: 0.5)
            )
            .overlay(content.padding())
            .shadow(color: .white.opacity(0.1), radius: 10, x: -2, y: 4)
            .padding(.horizontal)
    }
}

// MARK: - Glowing Holographic Button

@available(iOS 16.0, *)
struct HoloActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(.subheadline, design: .rounded))
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(colors: [color.opacity(0.5), color.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: color.opacity(0.6), radius: 10)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}



@available(iOS 16.0, *)
struct FrostedIconButton: View {
    var title: String
    var systemImage: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color.opacity(0.8), lineWidth: 1.5)
            )
            .cornerRadius(14)
            .shadow(color: color.opacity(0.3), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct PixelFrameBackground: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset = CGFloat(6)
        path.addRect(rect.insetBy(dx: inset, dy: inset))
        return path
    }
}


struct NeonButton: View {
    var label: String
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color)
                        .shadow(color: color.opacity(0.5), radius: 10)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}




// MARK: - Data Models
struct CanvasText: Identifiable {
    let id = UUID()
    var content: String
    var position: CGPoint
    var fontSize: CGFloat
    var fontColor: Color
}

struct Drawing: Identifiable {
    let id = UUID()
    var points: [CGPoint] = []
    var color: Color
    var lineWidth: CGFloat
    var lineStyle: LineStyle
}

struct SavedSketch: Identifiable, Codable {
    let id: UUID
    let image: UIImage
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id, date, imageData
    }
    
    init(id: UUID, image: UIImage, date: Date) {
        self.id = id
        self.image = image
        self.date = date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        let imageData = try container.decode(Data.self, forKey: .imageData)
        guard let image = UIImage(data: imageData) else {
            throw DecodingError.dataCorruptedError(forKey: .imageData, in: container, debugDescription: "Invalid image data")
        }
        self.image = image
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        guard let imageData = image.pngData() else {
            throw EncodingError.invalidValue(image, EncodingError.Context(codingPath: [CodingKeys.imageData], debugDescription: "Could not convert UIImage to PNG"))
        }
        try container.encode(imageData, forKey: .imageData)
    }
}

enum LineStyle: String, CaseIterable, Identifiable {
    case solid = "Solid"
    case dotted = "Dot"
    case dashed = "Dash"
    case double = "Double"
    case wavy = "Wave"
    
    var id: String { rawValue }
}

extension UIColor {
    convenience init(_ color: Color) {
        switch color {
        case PxSkchDesignTokens.Colors.retroRed:
            self.init(red: 0.9, green: 0.1, blue: 0.2, alpha: 1.0)
        case PxSkchDesignTokens.Colors.pixelBlue:
            self.init(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0)
        case PxSkchDesignTokens.Colors.neonYellow:
            self.init(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0)
        case PxSkchDesignTokens.Colors.gridGreen:
            self.init(red: 0.1, green: 0.7, blue: 0.3, alpha: 1.0)
        case PxSkchDesignTokens.Colors.glowPurple:
            self.init(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0)
        case PxSkchDesignTokens.Colors.darkGrid:
            self.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        default:
            self.init(white: 0, alpha: 1)
        }
    }
}



// MARK: - Volume Slider Extension
extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            slider?.value = volume
        }
    }
}


