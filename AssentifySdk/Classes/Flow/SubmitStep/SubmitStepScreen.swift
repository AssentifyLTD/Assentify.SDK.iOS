import SwiftUI

public enum SubmitDataTypes {
    public static let onSend     = "onSend"
    public static let onError    = "onError"
    public static let onComplete = "onComplete"
    public static let none       = "none"
}

// MARK: - SubmitStepScreen (SwiftUI - single view like your other screens)
public struct SubmitStepScreen: View ,SubmitDataDelegate {
    public func onSubmitError(message: String) {
        DispatchQueue.main.async {
            submitDataTypes = SubmitDataTypes.onError
        }
    }
    
    public func onSubmitSuccess() {
        DispatchQueue.main.async {
            submitDataTypes = SubmitDataTypes.onComplete
        }

    }
    

    public let flowController: FlowController

    @State private var submitDataTypes: String = SubmitDataTypes.onSend

    @State private var resetTick: Int = 0

    public init(flowController: FlowController) {
        self.flowController = flowController
    }

    public var body: some View {

        BaseBackgroundContainer {
            VStack(spacing: 0) {
                // Middle + Bottom
                VStack(spacing: 0) {

                    // =========================
                    // MIDDLE (takes remaining space)
                    // =========================
                    ZStack {
                        switch submitDataTypes {

                        case SubmitDataTypes.onSend:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(BaseTheme.baseTextColor)))
                                .scaleEffect(1.6)

                        case SubmitDataTypes.onError:
                            MiddleContent(
                                title: nil,
                                message: "We couldn't complete your submission. Check your connection and retry.",
                                messageColor: Color(BaseTheme.baseRedColor)
                            )

                        case SubmitDataTypes.onComplete:
                            MiddleContent(
                                title: "THANK YOU",
                                message: "Swipe the button below to continue.",
                                messageColor: Color(BaseTheme.baseTextColor)
                            )

                        default: // none
                            MiddleContent(
                                title: "Ready to Submit?",
                                message: "Swipe the button below to confirm your submission.",
                                messageColor: Color(BaseTheme.baseTextColor)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 12)

                    // =========================
                    // BOTTOM (fixed)
                    // =========================
                    if shouldShowSwipe {
                        SwipeToSubmit(
                            text: swipeText,
                            height: 75,
                            corner: 35,
                            resetKey: resetTick
                        ) {
                            onSubmit()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 30)
                    }
                }
            }.topBarBackLogo {
                onBack()
            }
        } .modifier(InterceptSystemBack(action: onBack))
        .onAppear {
            // Start submit when screen appears (like Activity onCreate)
            startSubmit()

            var wrapUp: SubmitRequestModel? = nil
            let initSteps = ConfigModelObject.shared.get()!.stepDefinitions

            for item in initSteps {
                if item.stepDefinition == StepsNames.wrapUp {

                    var values: [String: String] = [:]

                    for property in item.outputProperties {
                        if property.key.contains(WrapUpKeys.timeEnded) {
                            values[property.key] = getTimeUTC()
                        }
                    }

                    wrapUp = SubmitRequestModel(
                        stepId: item.stepId,
                        stepDefinition: StepsNames.wrapUp,
                        extractedInformation: values
                    )
                    
                    flowController.trackProgress(
                        currentStep : LocalStepModel(
                            name : "",
                            description : "",
                            iconAssetPath : "",
                            isDone : false,
                            stepDefinition : item,
                            submitRequestModel : wrapUp
                        ),
                        inputData: wrapUp?.extractedInformation,
                        response: "Completed",
                        status: "Completed"
                    )

                    break
                }
            }
            
            
            
        }
        .onChange(of: submitDataTypes) { newValue in
            // Kotlin behavior: when onError -> after 3s -> none (and reset swipe)
            if newValue == SubmitDataTypes.onError {
                resetTick += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if submitDataTypes == SubmitDataTypes.onError {
                        submitDataTypes = SubmitDataTypes.none
                    }
                }
            }
        }
    }


    // MARK: - Derived
    private var shouldShowSwipe: Bool {
        if submitDataTypes == SubmitDataTypes.onSend { return false }
        if submitDataTypes == SubmitDataTypes.onError { return false }
        // show swipe in "none" and in "onComplete"
        return true
    }

    private var swipeText: String {
        submitDataTypes == SubmitDataTypes.onComplete ? "Next" : "Swipe to Submit"
    }

    // MARK: - Actions
    private func onBack() {
        if submitDataTypes == SubmitDataTypes.onComplete {
            flowController.endFlow(submitRequestModel:flowController.getSubmitList())
        } else {
            flowController.backClick()
        }
    }

    private func onSubmit() {
        if submitDataTypes == SubmitDataTypes.onComplete {
            flowController.endFlow(submitRequestModel:flowController.getSubmitList())
        } else {
            startSubmit()
            submitDataTypes = SubmitDataTypes.onSend
        }
    }

    private func startSubmit() {
        AssentifySdkObject.shared.get()!.startSubmitData(
            submitDataDelegate: self,
            submitRequestModel: flowController.getSubmitList(),

        )
    }
}

// MARK: - Middle Content (Phone icon + logo + texts)
fileprivate struct MiddleContent: View {

    let title: String?
    let message: String
    let messageColor: Color

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                
                SVGAssetIcon(
                    name: "ic_phone.svg",
                    size: CGSize(width: 350, height: 330),
                    tintColor:BaseTheme.baseAccentColor
                )
                .frame(width: 350, height: 330)
                SecureImage(imageUrl: BaseTheme.baseLogo)
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .padding(.top, 40)
            }
            .padding(.bottom, 24)

            if let title {
                Text(title)
                    .foregroundColor(Color(BaseTheme.baseTextColor))
                    .font(.system(size: title == "THANK YOU" ? 38 : 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
            }

            Text(message)
                .foregroundColor(messageColor)
                .font(.system(size: 15, weight: .regular))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
    }
}

public struct SwipeToSubmit: View {

    public var text: String = "Swipe to Submit"
    public var height: CGFloat = 65
    public var corner: CGFloat = 35
    public var resetKey: AnyHashable? = nil
    public var onComplete: () -> Void

    @State private var knobOffset: CGFloat = 0
    @State private var knobTextWidth: CGFloat = 0

    // ✅ slower swipe factor (0.35 = much slower, 0.5 = medium, 0.7 = slightly slower)
    private let swipeSpeed: CGFloat = 0.45

    public init(
        text: String = "Swipe to Submit",
        height: CGFloat = 75,
        corner: CGFloat = 35,
        resetKey: AnyHashable? = nil,
        onComplete: @escaping () -> Void
    ) {
        self.text = text
        self.height = height
        self.corner = corner
        self.resetKey = resetKey
        self.onComplete = onComplete
    }

    public var body: some View {

        GeometryReader { geo in
            let w = geo.size.width
            let padding: CGFloat = 8
            let knobPadding: CGFloat = 6

            let knobMinWidth = (height - 12) * 2.2
            let knobWidth = max(knobMinWidth, knobTextWidth + 32)

            let maxOffset = max(0, w - padding * 2 - knobPadding - knobWidth)
            let threshold = maxOffset * 0.75

            ZStack {

                // Right arrows hint
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right.2")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(BaseTheme.baseTextColor).opacity(0.5))
                        .padding(.trailing, 18)
                }

                // Knob
                RoundedRectangle(cornerRadius: corner)
                    .fill(Color(BaseTheme.baseAccentColor))
                    .shadow(radius: 4)
                    .frame(width: knobWidth, height: height - 14)
                    .overlay(
                        Text(text)
                            .foregroundColor(Color(BaseTheme.baseTextColor))
                            .font(.system(size: 15, weight: .bold))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .background(
                                WidthReader(width: $knobTextWidth).hidden()
                            )
                            .padding(.horizontal, 16)
                    )
                    .offset(x: knobOffset - (w/2 - knobWidth/2 - padding), y: 0)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // ✅ slower movement
                                let delta = value.translation.width * swipeSpeed
                                let newOffset = knobOffset + delta
                                knobOffset = min(max(0, newOffset), maxOffset)
                            }
                            .onEnded { _ in
                                settle(threshold: threshold, maxOffset: maxOffset)
                            }
                    )
                    .animation(.easeOut(duration: 0.22), value: knobOffset) // ✅ slightly slower animation
            }
            // ✅ Rounded track for whole control
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BaseTheme.baseClickColor?.toSwiftUIBackground())
            .clipShape(RoundedRectangle(cornerRadius: corner))
            .padding(.horizontal, padding)
            .padding(.vertical, 10)
            .onChange(of: resetKey) { _ in
                knobOffset = 0
            }
        }
        .frame(height: height)
    }

    private func settle(threshold: CGFloat, maxOffset: CGFloat) {
        if knobOffset >= threshold {
            knobOffset = maxOffset
            onComplete()
        } else {
            knobOffset = 0
        }
    }
}

// MARK: - Helpers (measure text width)
fileprivate struct WidthReader: View {
    @Binding var width: CGFloat
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { width = geo.size.width }
                .onChange(of: geo.size.width) { width = $0 }
        }
    }
}
