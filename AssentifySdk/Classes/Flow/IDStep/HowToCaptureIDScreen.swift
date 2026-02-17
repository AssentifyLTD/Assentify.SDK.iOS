import SwiftUI
import AVKit

public struct HowToCaptureScreen: View {

    @Environment(\.dismiss) private var dismiss

    private func onBack () {
        self.flowController.pop();
    }
    public func onNext() {
        if(isPassport){
            self.flowController.push(PassportScanStep(flowController: self.flowController))
        }else{
            
        }
    }

    private let selectedTemplateId = SelectedTemplatesObject.shared.get()!.id;

    
    private let flowController: FlowController


    public init(flowController: FlowController) {
        self.flowController = flowController
    }

    private var isPassport: Bool { selectedTemplateId == -1 }

    private var titleText: String {
        isPassport ? "Present Your Passport" : "Present Your ID"
    }

    private var subTitleText: String {
        isPassport ? "Watch how easy it is to capture your Passport"
                  : "Watch how easy it is to capture your ID"
    }

    private var assetVideoFileName: String {
        isPassport ? "passport-video" : "id-video"
    }

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
                        AssetVideoPlayer(assetName: assetVideoFileName)
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

                        Text("Just make sure to be in a well lit area with no direct light reflecting on the ID or Passport presented.")
                            .foregroundColor(Color(BaseTheme.baseTextColor))
                            .font(.system(size: 12, weight: .thin))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 12)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .frame(maxHeight: .infinity)

                    // MARK: BOTTOM BUTTON (your reusable component)
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
                } .topBarBackLogo {
                    onBack()
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }.modifier(InterceptSystemBack(action: onBack))
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
