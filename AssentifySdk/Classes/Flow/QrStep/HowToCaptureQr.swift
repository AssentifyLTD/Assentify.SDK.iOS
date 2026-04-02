import SwiftUI
import AVKit
import WebKit

public struct HowToCaptureQrScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private func onBack () {
        self.flowController.backClick()
    }
    
    private func onNext() {
        flowController.push(QrScanStep(flowController: self.flowController))
    }
    
    private let flowController: FlowController
    
    public init(flowController: FlowController) {
        self.flowController = flowController
    }
    
    
    
    
    private var titleText = "Capture QR Code"
    private var subTitleText = "Watch How Easy It Is\nTo Capture Your ID Qr Code"
    private var assetGifFileName = "qr_gif"
    
    
    public var body: some View {
        BaseBackgroundContainer {
            
            VStack(spacing: 0) {
                
                // MARK: TOP SECTION
                VStack(spacing: 0) {
                    
                    Spacer().frame(height: 10)
                    
                    Text(titleText)
                        .foregroundColor(Color(BaseTheme.baseTextColor))
                        .font(.system(size: 25, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity)
                    
                    Spacer().frame(height: 20)
                    
                    // MARK: VIDEO (Flexible like weight(1f))
                    AssetVideoPlayer(assetName: "qr-video")
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal, 10)
                    
                    Spacer().frame(height: 20)
                    
                    Text(subTitleText)
                        .foregroundColor(Color(BaseTheme.baseTextColor))
                        .font(.system(size: 25, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 12)
                    
                    Spacer().frame(height: 20)
                    
                    Text("Just make sure to be in a well lit area with no direct light reflecting on the ID .")
                        .foregroundColor(Color(BaseTheme.baseTextColor))
                        .font(.system(size: 12, weight: .thin))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 12)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .frame(maxHeight: .infinity)
                
                BaseClickButton(
                    title: "Lets Start",
                    cornerRadius: 28,
                    verticalPadding: 15,
                    enabled: true
                ) {
                    onNext()
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 25)
            }
            .topBarBackLogo {
                onBack()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .modifier(InterceptSystemBack(action: onBack))
        .task {
            // ✅ runs once per appearance
        }
    }
}

private struct AssetVideoPlayer: View {

    let assetName: String
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()

                        // Loop video
                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem,
                            queue: .main
                        ) { _ in
                            player.seek(to: .zero)
                            player.play()
                        }
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            guard let url = Bundle.main.url(forResource: assetName, withExtension: "mp4") else {
                return
            }
            player = AVPlayer(url: url)
        }
    }
}
