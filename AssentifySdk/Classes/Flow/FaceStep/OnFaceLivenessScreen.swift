import SwiftUI

public struct OnFaceLivenessScreen: View {

    let imageUrl: String
    let isLivnessError: Bool
    let onRetry: () -> Void
    let onBack: () -> Void

    let steps: [LocalStepModel] = LocalStepsObject.shared.get()

    public init(
        imageUrl: String,
        isLivnessError: Bool,
        onRetry: @escaping () -> Void,
        onBack: @escaping () -> Void,
    ) {
        self.imageUrl = imageUrl
        self.isLivnessError = isLivnessError
        self.onRetry = onRetry
        self.onBack = onBack
    }

    public var body: some View {

        let accent = Color(BaseTheme.baseAccentColor)
        let text   = Color(BaseTheme.baseTextColor)

        BaseBackgroundContainer {
            VStack(spacing: 0) {
                    ProgressStepperView(
                        steps: steps,
                        bundle: .main,
                        onBack: {onBack()}
                    )
                    .padding(.top,
                             BaseTheme.stepperType == .normal ?
                             120 : 80)
               
                VStack(spacing: 0) {

                    Spacer().frame(height: 80)

                    ZStack {
                        SecureImage(imageUrl: imageUrl)
                            .frame(width: 300, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        if(isLivnessError){
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color(BaseTheme.baseAccentColor))
                        }else{
                            SVGAssetIcon(
                                name: "ic_error",
                                size: CGSize(width: 70, height:70),
                                tintColor: BaseTheme.baseAccentColor
                            ).frame(width: 70, height:70)
                        }
                      
                    }
                    .frame(height: 250)

                    Spacer().frame(height: 25)

                    if(isLivnessError){
                        Text("We couldn't verify a live face. Please try again.")
                            .foregroundColor(text)
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Spacer().frame(height: 15)

                        Text("We could not verify a live face. Please ensure you are in a well-lit area, and avoid using photos or videos")
                            .foregroundColor(text.opacity(0.85))
                            .font(.system(size: 10, weight: .thin))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 32)
                    }else{
                        Text("Let's try again")
                            .foregroundColor(text)
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Spacer().frame(height: 15)

                        Text("Please make sure your face is well lit, look directly at the camera, and avoid using photos or videos")
                            .foregroundColor(text.opacity(0.85))
                            .font(.system(size: 10, weight: .thin))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 32)
                    }
                   

                    Spacer(minLength: 0)

                    BaseClickButton(
                        title: "Retry",
                        cornerRadius: 28,
                        verticalPadding: 14,
                        enabled: true,
                        action: onRetry
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
