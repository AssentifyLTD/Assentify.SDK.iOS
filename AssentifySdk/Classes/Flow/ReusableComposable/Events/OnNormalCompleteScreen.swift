import SwiftUI

public struct OnNormalCompleteScreen: View {

    let imageUrl: String
    let showStper: Bool
    let onNext: () -> Void

    let steps: [LocalStepModel] = LocalStepsObject.shared.get()

    public init(
        imageUrl: String,
        showStper: Bool  = true,
        onNext: @escaping () -> Void
    ) {
        self.imageUrl = imageUrl
        self.onNext = onNext
        self.showStper = showStper
    }

    public var body: some View {

        let accent = Color(BaseTheme.baseAccentColor)
        let text   = Color(BaseTheme.baseTextColor)

        BaseBackgroundContainer {
            VStack(spacing: 0) {

                if(showStper){
                    ProgressStepperView(
                        steps: steps,
                        bundle: .main
                    )
                    .padding(.top, 120)
                }

                VStack(spacing: 0) {

                    Spacer().frame(height: 80)

                    ZStack {
                        SecureImage(imageUrl: imageUrl)
                            .frame(width: 300, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        SVGAssetIcon(
                            name: "ic_complete",
                            size: CGSize(width: 70, height:70),
                            tintColor: BaseTheme.baseAccentColor
                        ).frame(width: 70, height:70)
                    }
                    .frame(height: 250)

                    Spacer().frame(height: 25)

                    Text("ID Processed Successfully")
                        .foregroundColor(text)
                        .font(.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer().frame(height: 15)

                 

                    Spacer(minLength: 0)

                   

                    BaseClickButton(
                        title: "Next",
                        cornerRadius: 28,
                        verticalPadding: 14,
                        enabled: true,
                        action: onNext
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    .padding(.top, 24)
                }
            }
        }
        .ignoresSafeArea()
    }
}
