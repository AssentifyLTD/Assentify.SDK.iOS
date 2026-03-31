import SwiftUI
import UIKit
import SVGKit


public extension BackgroundStyle {

    func toSwiftUIBackground() -> AnyView {
        switch self {
        case .solid(let hex):
            return AnyView(Color(UIColor.fromHex(hex)))

        case .gradient(let colorsHex, let angleDegrees, let holdUntil):
            let first = Color(UIColor.fromHex(colorsHex.first ?? "#000000"))
            let last  = Color(UIColor.fromHex(colorsHex.last ?? "#000000"))

            let t = max(0, min(1, holdUntil))

            let stops: [Gradient.Stop] = [
                .init(color: first, location: 0.0),
                .init(color: first, location: t),
                .init(color: last,  location: 1.0)
            ]

            let (start, end): (UnitPoint, UnitPoint) = {
                if angleDegrees == 90 {
                    return (.top, .bottom)
                } else if angleDegrees == 0 {
                    return (.leading, .trailing)
                } else {
                    return (.topLeading, .bottomTrailing)
                }
            }()

            return AnyView(
                LinearGradient(gradient: Gradient(stops: stops), startPoint: start, endPoint: end)
            )
        }
    }

    func firstUIColor() -> UIColor {
        switch self {
        case .solid(let hex):
            return UIColor.fromHex(hex)
        case .gradient(let colorsHex, _, _):
            return UIColor.fromHex(colorsHex.first ?? "#000000")
        }
    }
}

struct BaseBackgroundContainer<Content: View>: View {
    let content: () -> Content

    var body: some View {
        switch BaseTheme.baseBackgroundType {
        case .color:
            ZStack {
                if let bg = BaseTheme.backgroundColor {
                    bg.toSwiftUIBackground()
                        .ignoresSafeArea()

                } else {
                    Color.clear.ignoresSafeArea()
                }
                content()
            }

        case .image:
            SvgUrlBackground(url: BaseTheme.baseBackgroundUrl) {
                AnyView(content())
            }
        }
    }
}



final class SvgDataCache {
    static let shared = NSCache<NSString, NSData>()
}

final class SvgImageCache {
    static let shared = NSCache<NSString, SVGKImage>()
}

struct SvgUrlBackground: View {
    let url: String
    let content: () -> AnyView

    @State private var svgData: Data?

    var body: some View {
        ZStack {
            if let svgData {
                SVGDataView(
                    data: svgData,
                    cacheKey: url
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
            } else {
                Color.clear
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            content()
        }
        .task(id: url) {
            await load()
        }
    }

    private func load() async {
        guard !url.isEmpty else { return }

        let cacheKey = url as NSString

        // 1) Return cached raw SVG data if available
        if let cachedData = SvgDataCache.shared.object(forKey: cacheKey) {
            self.svgData = cachedData as Data
            return
        }

        // 2) Download and cache
        guard let u = URL(string: url) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: u)

            SvgDataCache.shared.setObject(data as NSData, forKey: cacheKey)

            await MainActor.run {
                self.svgData = data
            }
        } catch {
            print("SvgUrlBackground load error: \(error)")
        }
    }
}

struct SVGDataView: UIViewRepresentable {
    typealias UIViewType = SVGKFastImageView

    let data: Data
    let cacheKey: String

    func makeUIView(context: Context) -> SVGKFastImageView {
        let emptyImage = SVGKImage()
        let view = SVGKFastImageView(svgkImage: emptyImage) ?? SVGKFastImageView()

        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        let imageCacheKey = cacheKey as NSString

        // 1) Return cached parsed SVG image if available
        if let cachedImage = SvgImageCache.shared.object(forKey: imageCacheKey) {
            uiView.image = cachedImage
            uiView.contentMode = .scaleAspectFill
            uiView.isUserInteractionEnabled = false
            return
        }

        // 2) Parse once, then cache
        guard let svgImage = SVGKImage(data: data) else { return }

        SvgImageCache.shared.setObject(svgImage, forKey: imageCacheKey)

        uiView.image = svgImage
        uiView.contentMode = .scaleAspectFill
        uiView.isUserInteractionEnabled = false
    }
}

