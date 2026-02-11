import SwiftUI

public struct BaseClickButton: View {
    public let title: String
    public let cornerRadius: CGFloat
    public let verticalPadding: CGFloat
    public let action: () -> Void

    public init(
        title: String = "Next",
        cornerRadius: CGFloat = 28,
        verticalPadding: CGFloat = 15,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.cornerRadius = cornerRadius
        self.verticalPadding = verticalPadding
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(BaseTheme.baseSecondaryTextColor))
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity)
        }
        .background(
            Group {
                if let click = BaseTheme.baseClickColor {
                    click.toSwiftUIBackground()
                } else {
                    Color.clear
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
