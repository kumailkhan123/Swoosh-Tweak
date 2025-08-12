import SwiftUI
import LinkPresentation
@available(iOS 16.0, *)

@available(iOS 17.0,*)
struct DashboardButton:View {
    var icon: String
    var title: String
    let destination: AnyView
    var body: some View {
        NavigationLink(destination: destination) {
            ZStack {
                GearShape(teeth: 15, toothDepth: 33)
                    .fill(Color.yellow)
                    
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 190, height: 190)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)

                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.cynn)

                    Text(title)
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                }
                .padding()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - DashboardView
@available(iOS 15.0, *)
@available(iOS 17.0,*)
struct DashboardView: View {
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationView {
            ZStack {
                PixelBackgroundView()
                    .ignoresSafeArea()

                VStack(spacing: -30) {
                    Text("Swoosh Tweak")
                        .font(.custom("times", size: 45).bold())
                        .foregroundColor(.teal)
                        .padding(.top, 40)

                    LazyVGrid(columns: gridItems, spacing: 20) {
                        DashboardButton(icon: "photo.on.rectangle", title: "Collage Maker", destination: AnyView(CollageMakerView()))
                        DashboardButton(icon: "arrow.down.to.line", title: "Compress Image", destination: AnyView(CompressImageView(selectedImage: self.$selectedImage)))
                        DashboardButton(icon: "waveform.circle", title: "Text to Listen", destination: AnyView(Text_to_Listen()))
                        DashboardButton(icon: "sun.max.fill", title: "More Brightness", destination: AnyView(BrightnessControlView()))

                    }
            
                    .padding(.top,90)
                    .padding(.bottom,40)
                    .padding(.trailing,-10)
                    .padding(.leading,-10)
                    Spacer()
                }
                .padding(.top,20)
            }
            .navigationTitle("Back")
                        .navigationBarHidden(true)
                        
        }
    }
}




// MARK: - Previews
@available(iOS 15.0, *)
@available(iOS 17.0,*)
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}


