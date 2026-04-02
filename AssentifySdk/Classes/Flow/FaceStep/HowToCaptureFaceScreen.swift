import SwiftUI
import AVKit

public struct HowToCaptureFaceScreen: View {

    @Environment(\.dismiss) private var dismiss

    private func onBack () {
        self.flowController.backClick()
    }

    private func onNext() {
        flowController.push(FaceMatchStep(flowController: self.flowController, secondImage: cachedBase64!))
    }

    private let flowController: FlowController
    private var docUrl = ""

    public init(flowController: FlowController) {
        self.flowController = flowController
        self.docUrl = normalizeUrlString(self.flowController.getPreviousIDImage())
    }

    private func normalizeUrlString(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // Handle: Optional("https://...")
        if s.hasPrefix("Optional(\"") && s.hasSuffix("\")") {
            s = String(s.dropFirst("Optional(\"".count).dropLast(2))
        }

        // Handle: "https://..." (extra quotes)
        if s.hasPrefix("\"") && s.hasSuffix("\"") && s.count >= 2 {
            s = String(s.dropFirst().dropLast())
        }

        return s
    }

    
    
    private var titleText = "Face Match"
    private var subTitleText = "Watch How Easy It Is\nTo Take A Selfie"
    private var assetVideoFileName = "face-video"

    // ✅ New states (logic only)
    @State private var cachedBase64: String? = nil
    @State private var isLoadingBase64: Bool = true

    // ✅ Async-safe base64 loader
    private func loadImageBase64(from urlString: String) async -> String? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // If it's a local file path, support it too
        if trimmed.hasPrefix("/") {
            let fileURL = URL(fileURLWithPath: trimmed)
            return await base64FromFile(fileURL)
        }

        guard let url = URL(string: trimmed) else { return nil }

        // local file:// url
        if url.isFileURL {
            return await base64FromFile(url)
        }

        // remote http/https
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return nil
            }
            return data.base64EncodedString()
        } catch {
            return nil
        }
    }

    private func base64FromFile(_ url: URL) async -> String? {
        // file reads are fast, but still keep it off the main thread
        return await withCheckedContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try Data(contentsOf: url)
                    cont.resume(returning: data.base64EncodedString())
                } catch {
                    cont.resume(returning: nil)
                }
            }
        }
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

                    Text("The selfie includes liveness capture to ensure you're real, follow the on screen instructions.")
                        .foregroundColor(Color(BaseTheme.baseTextColor))
                        .font(.system(size: 12, weight: .thin))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 12)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .frame(maxHeight: .infinity)

                // ✅ UI stays the same: button if base64 exists, else progress
                if let _ = cachedBase64 {
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

                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(BaseTheme.baseTextColor))
                        .scaleEffect(1.2).padding(.vertical, 25)
                }
            }
            .topBarBackLogo {
                onBack()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .modifier(InterceptSystemBack(action: onBack))
        .task {
            // ✅ runs once per appearance
            isLoadingBase64 = true
            cachedBase64 = await loadImageBase64(from: docUrl)
            isLoadingBase64 = false
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
