import SwiftUI
import UIKit
import PhotosUI

@available(iOS 15.0,*)
struct CollageMakerView: View {
    @State private var images: [UIImage?] = Array(repeating: nil, count: 4)
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showImagePicker = false
    @State private var selectedSlot: Int? = nil
    @State private var collageImage: UIImage?
    @State private var history: [UIImage] = []
    @State private var currentLayout: CollageLayout = .grid2x2
    @State private var showLayoutOptions = false
    
    enum CollageLayout: String, CaseIterable {
        case grid2x2 = "Grid"
        case verticalSplit = "Vertical"
        case horizontalSplit = "Horizontal"
        case mainWithSide = "Main + Side"
        
        var icon: String {
            switch self {
            case .grid2x2: return "square.grid.2x2"
            case .verticalSplit: return "rectangle.split.1x2"
            case .horizontalSplit: return "rectangle.split.2x1"
            case .mainWithSide: return "rectangle.leadingthird.inset.filled"
            }
        }
        
        var requiredImageCount: Int {
            switch self {
            case .grid2x2: return 4
            case .verticalSplit, .horizontalSplit: return 2
            case .mainWithSide: return 3
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Layout Selection
                        layoutPickerView
                        
                        // Image Grid
                        imageGridView
                            .padding(.horizontal)
                        
                        // Action Buttons
                        actionButtonsView
                        
                        // Collage Preview
                        if let collageImage = collageImage {
                            collagePreviewView(collageImage)
                        }
                        
                        // History Section
                        if !history.isEmpty {
                            historyView
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(
                    onPick: { image in
                        if let slot = selectedSlot {
                            images[slot] = image
                            toastMessage = "Image added!"
                            showToast = true
                        }
                        selectedSlot = nil
                    },
                    onCancel: { selectedSlot = nil }
                )
            }
            .toast(message: toastMessage, isShowing: $showToast, duration: 1.5)
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Pixel Collage")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showLayoutOptions.toggle() }) {
                    Image(systemName: "rectangle.3.group.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Divider()
        }
    }
    
    private var layoutPickerView: some View {
        Group {
            if showLayoutOptions {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Layout Style")
                        .font(.system(.subheadline))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(CollageLayout.allCases, id: \.self) { layout in
                                Button(action: {
                                    currentLayout = layout
                                    showLayoutOptions = false
                                }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: layout.icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(currentLayout == layout ? .white : .blue)
                                        Text(layout.rawValue)
                                            .font(.system(size: 12))
                                            .foregroundColor(currentLayout == layout ? .white : .primary)
                                    }
                                    .frame(width: 80, height: 80)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(currentLayout == layout ? .blue : Color(.secondarySystemFill))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
    
    private var imageGridView: some View {
        Group {
            switch currentLayout {
            case .grid2x2:
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        imageSlotView(index: index)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                
            case .verticalSplit:
                GeometryReader { geometry in
                    HStack(spacing: 12) {
                        imageSlotView(index: 0)
                            .frame(width: geometry.size.width / 2 - 6)
                        imageSlotView(index: 1)
                            .frame(width: geometry.size.width / 2 - 6)
                    }
                }
                .frame(height: 300)
                
            case .horizontalSplit:
                GeometryReader { geometry in
                    VStack(spacing: 12) {
                        imageSlotView(index: 0)
                            .frame(height: geometry.size.height / 2 - 6)
                        imageSlotView(index: 1)
                            .frame(height: geometry.size.height / 2 - 6)
                    }
                }
                .frame(height: 300)
                
            case .mainWithSide:
                GeometryReader { geometry in
                    HStack(spacing: 12) {
                        imageSlotView(index: 0)
                            .frame(width: geometry.size.width * 0.7)
                        VStack(spacing: 12) {
                            imageSlotView(index: 1)
                            imageSlotView(index: 2)
                        }
                        .frame(width: geometry.size.width * 0.3)
                    }
                }
                .frame(height: 300)
            }
        }
    }
    
    private func imageSlotView(index: Int) -> some View {
        Button(action: {
            selectedSlot = index
            showImagePicker = true
        }) {
            Group {
                if let image = images[index] {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color(.secondarySystemFill)
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .overlay(
                images[index] == nil ?
                Text("Tap to add")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(4)
                    .background(Color(.systemBackground).opacity(0.7))
                    .cornerRadius(4)
                : nil,
                alignment: .bottomTrailing
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 16) {
            // Create Button
            Button(action: createCollage) {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                    Text("Create")
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(canCreateCollage ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!canCreateCollage)
            
            // Reset Button
            Button(action: {
                withAnimation {
                    images = Array(repeating: nil, count: 4)
                    collageImage = nil
                }
                toastMessage = "Cleared all images"
                showToast = true
            }) {
                Image(systemName: "trash")
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    private var canCreateCollage: Bool {
        let availableImages = images.compactMap { $0 }.count
        return availableImages >= currentLayout.requiredImageCount
    }
    
    private func collagePreviewView(_ image: UIImage) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Collage")
                    .font(.system(.headline))
                    .foregroundColor(.primary)
                Spacer()
                
                // Share Button
                Button(action: { shareImage(image) }) {
                    Image(systemName: "square.and.arrow.up")
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
                
                // Save Button
                Button(action: { downloadImage(image) }) {
                    Image(systemName: "square.and.arrow.down")
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal)
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
        }
    }
    
    private var historyView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("History")
                    .font(.system(.headline))
                    .foregroundColor(.primary)
                Spacer()
                
                Button(action: {
                    withAnimation {
                        history.removeAll()
                    }
                    toastMessage = "Cleared history"
                    showToast = true
                }) {
                    Text("Clear")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(history, id: \.self) { historyItem in
                        historyItemView(historyItem)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func historyItemView(_ item: UIImage) -> some View {
        Button(action: {
            withAnimation {
                collageImage = item
            }
            toastMessage = "Collage restored"
            showToast = true
        }) {
            Image(uiImage: item)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
                .contextMenu {
                    Button(action: { downloadImage(item) }) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    Button(action: { shareImage(item) }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive, action: { deleteHistoryItem(item) }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Functions
    
    private func createCollage() {
        guard canCreateCollage else {
            toastMessage = "Need \(currentLayout.requiredImageCount) images for this layout"
            showToast = true
            return
        }
        
        let collageSize = CGSize(width: 600, height: 600)
        UIGraphicsBeginImageContextWithOptions(collageSize, false, 0.0)
        
        // White background
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: collageSize))
        
        switch currentLayout {
        case .grid2x2:
            let imageSize = CGSize(width: collageSize.width/2, height: collageSize.height/2)
            for (index, image) in images.prefix(4).enumerated() {
                if let image = image {
                    let x = CGFloat(index % 2) * imageSize.width
                    let y = CGFloat(index / 2) * imageSize.height
                    image.draw(in: CGRect(origin: CGPoint(x: x, y: y), size: imageSize))
                }
            }
            
        case .verticalSplit:
            if let leftImage = images[0], let rightImage = images[1] {
                leftImage.draw(in: CGRect(x: 0, y: 0, width: collageSize.width/2, height: collageSize.height))
                rightImage.draw(in: CGRect(x: collageSize.width/2, y: 0, width: collageSize.width/2, height: collageSize.height))
            }
            
        case .horizontalSplit:
            if let topImage = images[0], let bottomImage = images[1] {
                topImage.draw(in: CGRect(x: 0, y: 0, width: collageSize.width, height: collageSize.height/2))
                bottomImage.draw(in: CGRect(x: 0, y: collageSize.height/2, width: collageSize.width, height: collageSize.height/2))
            }
            
        case .mainWithSide:
            if let mainImage = images[0], let sideTop = images[1], let sideBottom = images[2] {
                mainImage.draw(in: CGRect(x: 0, y: 0, width: collageSize.width * 0.7, height: collageSize.height))
                sideTop.draw(in: CGRect(x: collageSize.width * 0.7, y: 0, width: collageSize.width * 0.3, height: collageSize.height/2))
                sideBottom.draw(in: CGRect(x: collageSize.width * 0.7, y: collageSize.height/2, width: collageSize.width * 0.3, height: collageSize.height/2))
            }
        }
        
        guard let newCollageImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            toastMessage = "Failed to create collage"
            showToast = true
            return
        }
        UIGraphicsEndImageContext()
        
        withAnimation {
            collageImage = newCollageImage
            // Only keep last 10 history items
            if history.count >= 10 {
                history.removeFirst()
            }
            history.append(newCollageImage)
        }
        
        toastMessage = "Collage created successfully!"
        showToast = true
    }
    
    private func downloadImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        toastMessage = "Saved to Photos"
        showToast = true
    }
    
    private func shareImage(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
    }
    
    private func deleteHistoryItem(_ item: UIImage) {
        withAnimation {
            history.removeAll(where: { $0 == item })
        }
        toastMessage = "Deleted from history"
        showToast = true
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

@available(iOS 15.0,*)
#Preview {
    CollageMakerView()
}

@available(iOS  15.0,*)
#Preview {
    CollageMakerView()
}
struct ImagePickerView: UIViewControllerRepresentable {
    var onPick: (UIImage) -> Void // non-optional
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onPick(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
            picker.dismiss(animated: true)
        }
    }
}
