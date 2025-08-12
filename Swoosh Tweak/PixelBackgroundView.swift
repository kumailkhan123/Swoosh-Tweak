//
//  PixelBackgroundView.swift
//  Pixorate
//
//  Created by .. on 05/06/2025.
//

import SwiftUI

struct PixelBackgroundView: View {
    @State private var floatingOffsets: [CGFloat] = (0..<15).map { _ in CGFloat.random(in: -500...300) }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background Gradient
                backgroundGradient
                
                // Small random dots
                randomDots(in: geo.size)
                
                // Floating gears
                floatingGears(in: geo.size)
                
                // Central glowing gear
                centralGear
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .onAppear {
                withAnimation {
                    floatingOffsets = floatingOffsets.map { _ in CGFloat.random(in: -10...50) }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                PxSkchDesignTokens.Colors.pixelBlue.opacity(0.4),
                PxSkchDesignTokens.Colors.neonYellow.opacity(0.2),
                PxSkchDesignTokens.Colors.darkGrid
            ]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
    
    private func randomDots(in size: CGSize) -> some View {
        ForEach(0..<50, id: \.self) { _ in
            Circle()
                .fill(PxSkchDesignTokens.Colors.retroRed.opacity(0.01))
                .frame(width: CGFloat.random(in: 3...5), height: CGFloat.random(in: 3...5))
                .position(
                    x: CGFloat.random(in: 10...size.width),
                    y: CGFloat.random(in: 10...size.height)
                )
                .blur(radius: 0.5)
        }
    }
    
    private func floatingGears(in size: CGSize) -> some View {
        ForEach(0..<floatingOffsets.count, id: \.self) { i in
            GearShape(teeth: 12, toothDepth: 15)
                .fill(Color.green)
                .frame(width: 60, height: 60)
               
                .position(
                    x: CGFloat.random(in: 0...size.width),
                    y: size.height / 2 + floatingOffsets[i]
                )
                .animation(
                    Animation.easeInOut(duration: Double.random(in: 4...8))
                        .repeatForever(autoreverses: true),
                    value: floatingOffsets[i]
                )
        }
    }
    
    private var centralGear: some View {
        GearShape(teeth: 9, toothDepth: 35)
            .fill(.blue.opacity(0.2))
            .frame(width: 200, height: 200)
            
            .blur(radius: 1)
            .shadow(color: PxSkchDesignTokens.Colors.glowPurple.opacity(0.3), radius: 50)
           
            .animation(Animation.linear(duration: 5).repeatForever(), value: UUID())
    }
}


struct PxSkchDesignTokens {
    struct Colors {
        static let pixelBlue = Color(red: 0.0, green: 0.4, blue: 0.8) // #0066CC
        static let retroRed = Color(red: 0.9, green: 0.1, blue: 0.2) // #E61A33
        static let neonYellow = Color(red: 1.0, green: 0.9, blue: 0.0) // #FFE600
        static let gridGreen = Color(red: 0.1, green: 0.7, blue: 0.3) // #1AB955
        static let darkGrid = Color(red: 0.1, green: 0.1, blue: 0.1) // #191919
        static let glowPurple = Color(red: 0.6, green: 0.2, blue: 0.8) // #9926CC
        static let fadeGray = Color(red: 0.3, green: 0.3, blue: 0.3, opacity: 0.8) // #4D4D4D
    }
    
    struct Typography {
        static let title = Font.custom("PressStart2P-Regular", size: 24)
        static let body = Font.custom("PressStart2P-Regular", size: 14)
        static let caption = Font.custom("PressStart2P-Regular", size: 12)
    }
}
import SwiftUI

struct HexShape: Shape {
    var cornerRadius: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)
        let radius = min(width, height) / 2
        
        var path = Path()
        
        for i in 0..<6 {
            let angle = Angle(degrees: Double(i) * 60 - 30).radians
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                if cornerRadius > 0 {
                    let prevAngle = Angle(degrees: Double(i-1) * 60 - 30).radians
                    let prevPoint = CGPoint(
                        x: center.x + cos(prevAngle) * radius,
                        y: center.y + sin(prevAngle) * radius
                    )
                    let control1 = CGPoint(
                        x: prevPoint.x + cos(prevAngle + .pi/6) * cornerRadius,
                        y: prevPoint.y + sin(prevAngle + .pi/6) * cornerRadius
                    )
                    let control2 = CGPoint(
                        x: point.x + cos(angle - .pi/6) * cornerRadius,
                        y: point.y + sin(angle - .pi/6) * cornerRadius
                    )
                    path.addCurve(to: point, control1: control1, control2: control2)
                } else {
                    path.addLine(to: point)
                }
            }
        }
        path.closeSubpath()
        return path
    }
}

// 2. Star Shape with customizable points
struct StarShape: Shape {
    let points: Int
    var innerRadiusRatio: CGFloat = 0.5
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio
        
        var path = Path()
        
        for i in 0..<points * 2 {
            let angle = Angle(degrees: Double(i) * 360 / Double(points * 2)).radians
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct SuperellipseShape: Shape {
    var n: CGFloat = 4 // Higher values make it more rectangular
    
    func path(in rect: CGRect) -> Path {
        let a = rect.width / 2
        let b = rect.height / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        return Path { path in
            let points = (0...360).map { degree -> CGPoint in
                let angle = Angle(degrees: Double(degree)).radians
                let cosAngle = cos(angle)
                let sinAngle = sin(angle)
                let x = pow(abs(cosAngle), 2/n) * a * (cosAngle > 0 ? 1 : -1)
                let y = pow(abs(sinAngle), 2/n) * b * (sinAngle > 0 ? 1 : -1)
                return CGPoint(x: center.x + x, y: center.y + y)
            }
            
            path.addLines(points)
        }
    }
}

// 4. Reuleaux Triangle (curved triangle)
struct ReuleauxTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        var path = Path()
        
        for i in 0..<3 {
            let startAngle = Angle(degrees: Double(i) * 120 + 60)
            let endAngle = Angle(degrees: Double(i+1) * 120 + 60)
            
            let vertex = CGPoint(
                x: center.x + cos(startAngle.radians) * radius,
                y: center.y + sin(startAngle.radians) * radius
            )
            
            if i == 0 {
                path.move(to: vertex)
            }
            
            path.addArc(
                center: CGPoint(
                    x: center.x + cos(endAngle.radians) * radius,
                    y: center.y + sin(endAngle.radians) * radius
                ),
                radius: radius * sqrt(3),
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
        }
        
        return path
    }
}

// 5. Gear Shape
struct GearShape: Shape {
    let teeth: Int
    let toothDepth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        var path = Path()
        
        for i in 0..<teeth {
            let angle1 = Angle(degrees: Double(i) * 360 / Double(teeth)).radians
            let angle2 = Angle(degrees: (Double(i) + 0.5) * 360 / Double(teeth)).radians
            
            let outerPoint1 = CGPoint(
                x: center.x + cos(angle1) * radius,
                y: center.y + sin(angle1) * radius
            )
            
            let innerPoint = CGPoint(
                x: center.x + cos(angle1 + .pi / Double(teeth)) * (radius - toothDepth),
                y: center.y + sin(angle1 + .pi / Double(teeth)) * (radius - toothDepth)
            )
            
            let outerPoint2 = CGPoint(
                x: center.x + cos(angle2) * radius,
                y: center.y + sin(angle2) * radius
            )
            
            if i == 0 {
                path.move(to: outerPoint1)
            }
            
            path.addLine(to: innerPoint)
            path.addLine(to: outerPoint2)
        }
        
        path.closeSubpath()
        return path
    }
}

// Usage Examples:
struct ShapePreview: View {
    var body: some View {
        VStack(spacing: 20) {
            // Hexagon with rounded corners
            HexShape(cornerRadius: 4)
                .fill(Color.blue)
                .frame(width: 100, height: 100)
            
            // 5-pointed star
            StarShape(points: 4)
                .fill(Color.yellow)
                .frame(width: 100, height: 100)
            
            // Squircle
            SuperellipseShape(n: 0.6)
                .fill(Color.purple)
                .frame(width: 200, height: 200)
            
            // Reuleaux Triangle
            ReuleauxTriangle()
                .fill(Color.red)
                .frame(width: 20, height: 20)
            
            // Gear with 12 teeth
            GearShape(teeth: 12, toothDepth: 15)
                .fill(Color.green)
                .frame(width: 100, height: 100)
        }
        .padding()
    }
}
#Preview{
    PixelBackgroundView()
}
