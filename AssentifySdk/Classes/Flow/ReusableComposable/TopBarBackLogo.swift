import SwiftUI

public struct TopBarBackLogoToolbar: ViewModifier {

    let onBack: () -> Void
    let logoUrl: String

    public init(
        logoUrl: String = BaseTheme.baseLogo,
        onBack: @escaping () -> Void
    ) {
        self.logoUrl = logoUrl
        self.onBack = onBack
    }

    public func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(BaseTheme.baseTextColor))
                            .padding(.vertical, 6) // nicer tap area
                            .contentShape(Rectangle())
                    }
                }

                ToolbarItem(placement: .principal) {
                    AsyncImage(url: URL(string: logoUrl)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFit()
                        default:
                            Color.clear
                        }
                    }
                    .frame(height: 28)
                }
            }
    }
}

public extension View {
    func topBarBackLogo(
        logoUrl: String = BaseTheme.baseLogo,
        onBack: @escaping () -> Void
    ) -> some View {
        self.modifier(TopBarBackLogoToolbar(logoUrl: logoUrl, onBack: onBack))
    }
}
