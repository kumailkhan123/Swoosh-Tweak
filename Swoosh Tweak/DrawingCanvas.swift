//
//  DrawingCanvas.swift
//  Pixorate
//
//  Created by .. on 05/06/2025.
//

import SwiftUI

struct DrawingCanvas: View {
    @Binding var drawings: [Drawing]
    @Binding var addedTexts: [CanvasText]
    var selectedColor: Color
    var lineWidth: CGFloat
    var lineStyle: LineStyle
    var canvasBackground: Color
    var onDrawingChanged: () -> Void
    
    @State private var currentDrawing: Drawing
    
    init(
        drawings: Binding<[Drawing]>,
        addedTexts: Binding<[CanvasText]>,
        selectedColor: Color,
        lineWidth: CGFloat,
        lineStyle: LineStyle,
        canvasBackground: Color,
        onDrawingChanged: @escaping () -> Void
    ) {
        self._drawings = drawings
        self._addedTexts = addedTexts
        self.selectedColor = selectedColor
        self.lineWidth = lineWidth
        self.lineStyle = lineStyle
        self.canvasBackground = canvasBackground
        self.onDrawingChanged = onDrawingChanged
        _currentDrawing = State(initialValue: Drawing(color: selectedColor, lineWidth: lineWidth, lineStyle: lineStyle))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                canvasBackground
                    .clipShape(PixelBlock())
                ForEach(drawings) { drawing in
                    Path { path in
                        if let first = drawing.points.first {
                            path.move(to: first)
                            for point in drawing.points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(drawing.color, style: strokeStyle(for: drawing.lineStyle, lineWidth: drawing.lineWidth))
                }
                Path { path in
                    if let first = currentDrawing.points.first {
                        path.move(to: first)
                        for point in currentDrawing.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(currentDrawing.color, style: strokeStyle(for: lineStyle, lineWidth: currentDrawing.lineWidth))
                ForEach(addedTexts) { text in
                    Text(text.content)
                        .font(.custom("PressStart2P-Regular", size: text.fontSize))
                        .foregroundColor(text.fontColor)
                        .position(text.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if let index = addedTexts.firstIndex(where: { $0.id == text.id }) {
                                        addedTexts[index].position = value.location
                                    }
                                }
                        )
                        .contextMenu {
                            Button(action: {
                                if let index = addedTexts.firstIndex(where: { $0.id == text.id }) {
                                    addedTexts.remove(at: index)
                                }
                            }) {
                                Text("Remove")
                                Image(systemName: "trash")
                            }
                        }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentDrawing.points.append(value.location)
                        currentDrawing.color = selectedColor
                        currentDrawing.lineWidth = lineWidth
                        currentDrawing.lineStyle = lineStyle
                    }
                    .onEnded { _ in
                        drawings.append(currentDrawing)
                        onDrawingChanged()
                        currentDrawing = Drawing(color: selectedColor, lineWidth: lineWidth, lineStyle: lineStyle)
                    }
            )
        }
    }
    
    private func strokeStyle(for style: LineStyle, lineWidth: CGFloat) -> StrokeStyle {
        switch style {
        case .solid:
            return StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        case .dotted:
            return StrokeStyle(lineWidth: lineWidth, lineCap: .round, dash: [lineWidth * 2, lineWidth * 5])
        case .dashed:
            return StrokeStyle(lineWidth: lineWidth, lineCap: .round, dash: [lineWidth * 8, lineWidth * 4])
        case .double:
            return StrokeStyle(lineWidth: lineWidth * 1.5, lineCap: .round)
        case .wavy:
            return StrokeStyle(lineWidth: lineWidth, lineCap: .round, dash: [lineWidth * 4, lineWidth * 2])
        }
    }
}


