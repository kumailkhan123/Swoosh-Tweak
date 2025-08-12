import SwiftUI
import UIKit
import PhotosUI

@available(iOS 15.0, *)
struct CompressImageView: View {
    @Binding var selectedImage: UIImage?
    @State private var showModal = false
    @State private var modalMessage = ""
    @State private var modalTitle = ""
    @State private var modalIcon = ""
    @State private var modalColor: Color = .blue
    @State private var showImagePicker = false
    @State private var compressedImage: UIImage?
    @State private var compressionRatio: Float = 0.5
    @State private var imageHistory: [(image: UIImage, compression: Float)] = []
    @State private var showHistory = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        imageDisplaySection
                        
                        compressionControlsSection
                        
                        actionButtonsSection
                        
                        if showHistory && !imageHistory.isEmpty {
                            imageHistorySection
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Image Compressor")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(
                    onPick: { image in
                        selectedImage = image
                        compressedImage = nil
                    },
                    onCancel: {}
                )
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityViewController(activityItems: shareItems)
            }
            .overlay(
                showModal ? AdorableAlertView(
                    icon: modalIcon,
                    title: modalTitle,
                    message: modalMessage,
                    color: modalColor,
                    dismissAction: { showModal = false }
                ) : nil
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.stack")
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .padding(12)
                .background(Circle().fill(Color.blue.opacity(0.1)))
            
            Text("Image Compressor")
                .font(.title2.bold())
            
            Text("Reduce image size while maintaining quality")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var imageDisplaySection: some View {
        Group {
            if let image = activeImage {
                VStack(spacing: 12) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Compression").font(.caption)
                            Text("\(Int(compressionRatio * 100))%").bold()
                        }
                        
                        Divider().frame(height: 30).padding(.horizontal, 8)
                        
                        VStack(alignment: .leading) {
                            Text("Size").font(.caption)
                            Text("\(image.sizeInKB) KB").bold()
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
            } else {
                placeholderSection
            }
        }
    }
    
    private var placeholderSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo")
                .font(.system(size: 60))
                .foregroundColor(Color(.quaternaryLabel))
            
            Text("No Image Selected").font(.headline)
            
            Button(action: { showImagePicker = true }) {
                Label("Select Image", systemImage: "photo.on.rectangle")
             
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var compressionControlsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Compression Level").bold()
                Spacer()
                Text("\(Int(compressionRatio * 100))%")
            }
            
            Slider(value: $compressionRatio, in: 0.1...1.0, step: 0.05)
                .tint(.blue)
            
            HStack {
                Text("Low Quality").font(.caption2)
                Spacer()
                Text("High Quality").font(.caption2)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if activeImage != nil {
                HStack(spacing: 12) {
                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: clearImage) {
                        Image(systemName: "trash")
                            .font(.body.bold())
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                
                Button(action: compressImage) {
                    Label("Compress Image", systemImage: "arrow.down.circle")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                HStack(spacing: 12) {
                    actionButton(icon: "square.and.arrow.up", label: "Share", color: .green, action: {shareImage()})
                    actionButton(icon: "square.and.arrow.down", label: "Save", color: .orange, action: {saveImage()})
                    actionButton(icon: "doc.on.doc", label: "Copy", color: .purple, action: {copyImage()})
                }
                
                if !imageHistory.isEmpty {
                    Button(action: { withAnimation { showHistory.toggle() } }) {
                        Label(showHistory ? "Hide History" : "Show History", systemImage: showHistory ? "chevron.up" : "clock.arrow.circlepath")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }
            } else {
                Button(action: { showImagePicker = true }) {
                    Label("Select Image", systemImage: "photo")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                Text(label).font(.caption2.bold())
            }
            .foregroundColor(.white)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(8)
        }
    }
    
    private var imageHistorySection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Compression History").bold()
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(imageHistory.indices.reversed(), id: \.self) { index in
                        historyItemView(item: imageHistory[index], index: index)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func historyItemView(item: (image: UIImage, compression: Float), index: Int) -> some View {
        VStack(spacing: 6) {
            Image(uiImage: item.image)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .onTapGesture { restoreFromHistory(item: item) }
            
            Text("\(Int(item.compression * 100))%").bold()
        }
        .contextMenu {
            Button(action: { restoreFromHistory(item: item) }) {
                Label("Restore", systemImage: "arrow.uturn.backward")
            }
            Button(action: { copyImage(image: item.image) }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            Button(action: { saveImage(image: item.image) }) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            Button(action: { shareImage(image: item.image) }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Divider()
            Button(role: .destructive, action: { removeFromHistory(at: index) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    private func toggleHistory() {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showHistory.toggle()
            }
        }
        
        private func restoreFromHistory(item: (image: UIImage, compression: Float)) {
            withAnimation {
                compressedImage = item.image
                compressionRatio = item.compression
            }
        }
        
        private func removeFromHistory(at index: Int) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                imageHistory.remove(at: index)
                if imageHistory.isEmpty {
                    showHistory = false
                }
            }
        }
        
        private func clearHistory() {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                imageHistory.removeAll()
                showHistory = false
            }
        }
    private var activeImage: UIImage? {
        compressedImage ?? selectedImage
    }
    
    private func compressImage() {
        guard let image = selectedImage else { return }
        guard let imageData = image.jpegData(compressionQuality: CGFloat(compressionRatio)) else { return }
        
        compressedImage = UIImage(data: imageData)
        
        if let compressedImage = compressedImage {
            if imageHistory.last?.image != compressedImage {
                imageHistory.append((image: compressedImage, compression: compressionRatio))
            }
            showMessage("Image compressed to \(Int(compressionRatio * 100))%", title: "Compressed!", icon: "arrow.down.circle.fill", color: .blue)
        }
    }
    
    private func clearImage() {
        selectedImage = nil
        compressedImage = nil
    }
    
    private func copyImage(image: UIImage? = nil) {
        let imageToCopy = image ?? activeImage
        guard let img = imageToCopy else { return }
        UIPasteboard.general.image = img
        showMessage("Image copied", title: "Copied!", icon: "doc.on.clipboard.fill", color: .purple)
    }
    
    private func saveImage(image: UIImage? = nil) {
        let imageToSave = image ?? activeImage
        guard let img = imageToSave else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        showMessage("Image saved", title: "Saved!", icon: "heart.fill", color: .pink)
    }
    
    private func shareImage(image: UIImage? = nil) {
        let imageToShare = image ?? activeImage
        guard let img = imageToShare else { return }
        shareItems = [img]
        showShareSheet = true
    }
    
   
    
    private func showMessage(_ message: String, title: String, icon: String, color: Color) {
        modalMessage = message
        modalTitle = title
        modalIcon = icon
        modalColor = color
        showModal = true
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct AdorableAlertView: View {
    var icon: String
    var title: String
    var message: String
    var color: Color
    var dismissAction: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { dismissAction() }
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: icon)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(color)
                        .scaleEffect(animate ? 1.1 : 1.0)
                }
                .padding(.top, 20)
                
                VStack(spacing: 8) {
                    Text(title).font(.title2.bold())
                    Text(message).multilineTextAlignment(.center).padding(.horizontal, 20)
                }
                
                Button(action: dismissAction) {
                    Text("Got it!")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(color)
                        .cornerRadius(20)
                        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.bottom, 20)
            }
            .frame(width: 280)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .scaleEffect(animate ? 1.0 : 0.8)
            .opacity(animate ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}



extension UIImage {
    var sizeInKB: Int {
        guard let data = self.jpegData(compressionQuality: 1.0) else { return 0 }
        return data.count / 1024
    }
}

@available(iOS 15.0,*)
struct CompressImageView_Previews: PreviewProvider {
    static var previews: some View {
        @State var previewSelectedImage: UIImage? = UIImage(systemName: "photo")
        return CompressImageView(selectedImage: $previewSelectedImage)
    }
}
