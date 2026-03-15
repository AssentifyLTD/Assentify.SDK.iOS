import SwiftUI
import UIKit

// MARK: - Events / State

struct FaceMatchEvents {
    var onSend: (() -> Void)? = nil
    var onProgress: ((Double) -> Void)? = nil
    var onComplete: ((FaceResponseModel) -> Void)? = nil
    var onError: ((RemoteProcessingModel) -> Void)? = nil
    var onRetry: ((RemoteProcessingModel) -> Void)? = nil
    var onLiveness: ((RemoteProcessingModel) -> Void)? = nil

    var onEnvironmental: ((BrightnessEvents, MotionType, FaceEvents, ZoomType, Int, Bool) -> Void)? = nil
    var onCurrentLiveMove: ((ActiveLiveEvents) -> Void)? = nil
    var onCollectingManualImages: (() -> Void)? = nil

}

enum FaceMatchScreenEvent {
    case idle
    case sending
    case completed
    case error
    case retry
    case liveness
}

final class FaceMatchCommands: ObservableObject {
    @Published var triggerRetry: Int = 0
    @Published var triggerClose: Int = 0
    @Published var triggerCapture: Int = 0

}

// MARK: - SwiftUI Step

public struct FaceMatchStep: View {

    @State private var start: Bool = false
    @State private var feedbackText: String = ""
    @State private var imageUrl: String = ""
    @State private var dataModel: FaceResponseModel? = nil
    @StateObject private var commands = FaceMatchCommands()
    @State private var uploadProgress: Int = 0
    @State private var screenEvent: FaceMatchScreenEvent = .idle
    @State private var currentActiveLiveEvents: ActiveLiveEvents = .GOOD
    private let timeStarted :String = getCurrentDateTimeForTracking();
    
    private var assentifySdk = AssentifySdkObject.shared.get()
    private let flowController: FlowController

    
    /// required by your SDK signature
    private let secondImage: String

    public init(
        flowController: FlowController,
        secondImage: String,
    ) {
        self.flowController = flowController
        self.secondImage = secondImage
        /** Track Progress **/
        let currentStep = flowController.getCurrentStep()
        flowController.trackProgress(
            currentStep : currentStep!,
            inputData : flowController.outputPropertiesToMap(currentStep!.stepDefinition!.outputProperties),
            response : nil,
            status : "InProgress"
        )
        /***/
        
    }

    private func onBack() {
        commands.triggerClose += 1
        flowController.pop()
    }

    private func onNext() {
        DispatchQueue.main.async { screenEvent = .idle }
        commands.triggerClose += 1
           guard
               let extractedModel = dataModel!.faceExtractedModel,
               let rawOutputProps = extractedModel.outputProperties
           else {
               return
           }
           
           var outputProps: [String: String] = rawOutputProps.mapValues {
               String(describing: $0)
           }
           
           IDImageObject.shared.clear()
           
           if let percentageMatch = extractedModel.percentageMatch,
              percentageMatch <= 50 {
               
               if let skippedKey = outputProps.keys.first(where: {
                   $0.contains("OnBoardMe_FaceImageAcquisition_IsSkippedStatus")
               }) {
                   outputProps[skippedKey] = "true"
               }
           }
           flowController.makeCurrentStepDone(extractedInformation: outputProps,timeStarted: self.timeStarted)
           flowController.naveToNextStep()
    }

    public var body: some View {

        let events = FaceMatchEvents(
            onSend: {
                DispatchQueue.main.async { start = true }
            },
            onProgress: { p in
                DispatchQueue.main.async {
                    screenEvent = .sending
                    uploadProgress = Int(p * 100)
                }
            },
            onComplete: { model in
                DispatchQueue.main.async {
                    feedbackText = ""
                    dataModel = model
                    start = false
                    imageUrl = model.faceExtractedModel?.secondImageFace ?? ""
                    screenEvent = .completed
                    
                    /** Track Progress **/
                    let currentStep = flowController.getCurrentStep()
                   

                    flowController.trackProgress(
                        currentStep: currentStep!,
                        inputData: model.faceExtractedModel?.outputProperties,
                        response: "Completed",
                        status: "InProgress"
                    )
                    /***/
                }
            },
            onError: { model in
                DispatchQueue.main.async {
                    feedbackText = ""
                    start = false
                    imageUrl = getImageUrlFromBaseResponseDataModel(jsonString: model.response)
                    screenEvent = .error
                    
                    /** Track Progress **/
                    let currentStep = flowController.getCurrentStep()
                    let errorString = model.responseJsonObject?["error"] as? String
                    let extracted = flowController.extractAfterDash(errorString)

                    let finalResponse = extracted.isEmpty
                        ? "Error"
                        : "Error - \(extracted)"

                    flowController.trackProgress(
                        currentStep: currentStep!,
                        inputData: flowController.decodeToJsonObject(model.response),
                        response: finalResponse,
                        status: "InProgress"
                    )
                    /***/
                }
            },
            onRetry: { model in
                DispatchQueue.main.async {
                    feedbackText = ""
                    start = false
                    imageUrl = getImageUrlFromBaseResponseDataModel(jsonString: model.response)
                    screenEvent = .retry
                    
                    /** Track Progress **/
                    let currentStep = flowController.getCurrentStep()
                    let errorString = model.responseJsonObject?["error"] as? String
                    let extracted = flowController.extractAfterDash(errorString)

                    let finalResponse = extracted.isEmpty
                        ? "onRetry"
                        : "onRetry - \(extracted)"

                    flowController.trackProgress(
                        currentStep: currentStep!,
                        inputData: flowController.decodeToJsonObject(model.response),
                        response: finalResponse,
                        status: "InProgress"
                    )
                    /***/
                }
            },
            onLiveness: { model in
                DispatchQueue.main.async {
                    feedbackText = ""
                    start = false
                    imageUrl = getImageUrlFromBaseResponseDataModel(jsonString: model.response)
                    screenEvent = .liveness
                    
                    /** Track Progress **/
                    let currentStep = flowController.getCurrentStep()
                    let errorString = model.responseJsonObject?["error"] as? String
                    let extracted = flowController.extractAfterDash(errorString)

                    let finalResponse = extracted.isEmpty
                        ? "onLivenessUpdate"
                        : "onLivenessUpdate - \(extracted)"

                    flowController.trackProgress(
                        currentStep: currentStep!,
                        inputData: flowController.decodeToJsonObject(model.response),
                        response: finalResponse,
                        status: "InProgress"
                    )
                    /***/
                }
            },
            onEnvironmental: { brightness, motion, faceEvents, zoom, detectedFaces, isCentered in
                DispatchQueue.main.async {
                    // same condition as Kotlin:
                    // if (start == false && currentActiveLiveEvents == Good) { ... } else { ... }
                    if start == false && currentActiveLiveEvents == .GOOD {
                        if detectedFaces > 1 {
                            feedbackText = "We detected more than one face.Please keep just your face in view."
                        } else if zoom != .SENDING && zoom != .NO_DETECT {
                            if zoom == .ZOOM_IN { feedbackText = "Please Move Closer" }
                            else if zoom == .ZOOM_OUT { feedbackText = "Please Move Further" }
                            else { feedbackText = "" }
                        } else if motion != .SENDING && motion != .NO_DETECT {
                            feedbackText = "Please Hold Your Hand"
                        } else if brightness != .Good {
                            if brightness == .TooDark { feedbackText = "Please increase the lighting" }
                            else if brightness == .TooBright { feedbackText = "Please reduce the lighting" }
                            else { feedbackText = "" }
                        } else if faceEvents != .GOOD && faceEvents != .NO_DETECT {
                            switch faceEvents {
                            case .ROLL_LEFT:
                                feedbackText = "Please tilt your head to the right"
                            case .ROLL_RIGHT:
                                feedbackText = "Please tilt your head to the left"
                            case .YAW_LEFT:
                                feedbackText = "Please turn your head to the right"
                            case .YAW_RIGHT:
                                feedbackText = "Please turn your head to the left"
                            case .PITCH_UP:
                                feedbackText = "Please lower your head"
                            case .PITCH_DOWN:
                                feedbackText = "Please raise your head"
                            default:
                                feedbackText = ""
                            }
                        } else {
                            if motion == .SENDING && zoom == .SENDING && brightness == .Good && faceEvents == .GOOD {
                                feedbackText = "Hold Steady"
                            }
                            if motion == .NO_DETECT && zoom == .NO_DETECT && faceEvents == .NO_DETECT {
                                feedbackText = "Please face within circle"
                            } else if !isCentered {
                                feedbackText = "Please center your face"
                            }
                        }
                    } else {
                        if currentActiveLiveEvents == .GOOD {
                            feedbackText = ""
                        }
                    }
                }
            },
            onCurrentLiveMove: { active in
                DispatchQueue.main.async {
                    currentActiveLiveEvents = active
                    if active != .GOOD {
                        switch active {
                        case .YAW_LEFT:
                            feedbackText = "Please move your face left"
                        case .YAW_RIGHT:
                            feedbackText = "Please move your face right"
                        case .PITCH_UP:
                            feedbackText = "Please move your face up"
                        case .PITCH_DOWN:
                            feedbackText = "Please move your face down"
                        case .WINK_LEFT:
                            feedbackText = "Please wink with your left eye"
                        case .WINK_RIGHT:
                            feedbackText = "Please wink with your right eye"
                        case .BLINK:
                            feedbackText = "Please blink your eyes"
                        case .GOOD:
                            feedbackText = ""
                        default:
                            feedbackText = ""
                        }
                    }
                }
            },
            onCollectingManualImages: {
                DispatchQueue.main.async {
                    feedbackText = "Hold Steady"
                }
            }
        )

        ZStack {

            FaceMatchUIKitView(
                flowController: flowController,
                secondImage: secondImage,
                events: events,
                commands: commands
            )
            .ignoresSafeArea()

            if screenEvent == .idle {
                VStack {
                    Spacer()
                    if !(assentifySdk?.isManual() ?? false) {
                        Text(feedbackText)
                            .foregroundColor(Color(BaseTheme.baseAccentColor))
                            .font(.system(size: 15, weight: .light))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .padding(.bottom, 40)
                    } else {
                        if(!feedbackText.isEmpty){
                            Text(feedbackText)
                                .foregroundColor(Color(BaseTheme.baseAccentColor))
                                .font(.system(size: 15, weight: .light))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .padding(.bottom, 40)
                        }
                       
                        
                        BaseClickButton(
                            title: "Take Photo",
                            cornerRadius: 28,
                            verticalPadding: 15,
                            enabled: true
                        ) {
                            commands.triggerCapture += 1
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 25)
                    }
                }
                .zIndex(1)
            }

            switch screenEvent {
            case .idle:
                EmptyView()

            case .sending:
                OnFaceSendScreen(progress: uploadProgress)
                    .ignoresSafeArea()
                    .background(Color.black.opacity(0.35).ignoresSafeArea())
                    .zIndex(999)
                    .allowsHitTesting(true)
                    .transition(.opacity)

            case .completed:
                // Use your own success screen here (example)
                FaceResultScreen(
                    faceModel: dataModel ?? FaceResponseModel(),
                    onNext: onNext,
                    onRetry: {
                        onBack()
                    },
                    onIDChange: {
                        flowController.faceIDChange();
                        flowController.backClick()
                    }
                )

            case .error, .retry, .liveness:
                OnFaceLivenessScreen(imageUrl: imageUrl) {
                    DispatchQueue.main.async {
                        screenEvent = .idle
                        start = true
                        commands.triggerRetry += 1
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: start)
        .topBarBackLogo { onBack() }
        .modifier(InterceptSystemBack(action: onBack))
    }
}

// MARK: - UIKit Bridge (same pattern as Passport)

struct FaceMatchUIKitView: UIViewControllerRepresentable {

    typealias UIViewControllerType = HostVC

    let flowController: FlowController
    let secondImage: String
    let events: FaceMatchEvents
    @ObservedObject var commands: FaceMatchCommands

    func makeCoordinator() -> Coordinator {
        Coordinator(flowController: flowController, events: events)
    }

    func makeUIViewController(context: Context) -> HostVC {
        let vc = HostVC()
        vc.flowController = flowController
        vc.secondImage = secondImage
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: HostVC, context: Context) {
        uiViewController.apply(commands: commands)
    }

    // MARK: - Coordinator (Delegate lives here)
    final class Coordinator: NSObject, FaceMatchDelegate {

        let flowController: FlowController
        let events: FaceMatchEvents

        init(flowController: FlowController, events: FaceMatchEvents) {
            self.flowController = flowController
            self.events = events
        }

        func onSend() {
            events.onSend?()
        }

        @objc func onUploadingProgress(progress: Double) {
            events.onProgress?(progress)
        }

        func onComplete(dataModel: FaceResponseModel) {
            events.onComplete?(dataModel)
        }

        func onError(dataModel: RemoteProcessingModel) {
            events.onError?(dataModel)
        }

        func onRetry(dataModel: RemoteProcessingModel) {
            events.onRetry?(dataModel)
        }
        
        func onLivenessUpdate(dataModel: RemoteProcessingModel ){
            events.onLiveness?(dataModel)
        }

        // Optional delegate
        func onEnvironmentalConditionsChange(
            brightnessEvents: BrightnessEvents,
            motion: MotionType,
            faceEvents: FaceEvents,
            zoom: ZoomType,
            detectedFaces: Int,
            isCentered: Bool
        ) {
            events.onEnvironmental?(brightnessEvents, motion, faceEvents, zoom, detectedFaces, isCentered)
        }

        // Optional delegate
        func onCurrentLiveMoveChange(activeLiveEvents: ActiveLiveEvents) {
            events.onCurrentLiveMove?(activeLiveEvents)
        }
        
        func onCollectingManualImages() {
            events.onCollectingManualImages?();
        }
    }

    // MARK: - UIKit Host VC
    final class HostVC: UIViewController {

        weak var delegate: FaceMatchDelegate?
        var flowController: FlowController?

        var secondImage: String = ""

        private var faceVC: FaceMatch?
        private var assentifySdk = AssentifySdkObject.shared.get()

        private var lastRetryTrigger: Int = 0
        private var lastCloseTrigger: Int = 0
        private var lastCaptureTrigger: Int = 0

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
            startFaceIfNeeded()
        }

        func apply(commands: FaceMatchCommands) {
            if commands.triggerRetry != lastRetryTrigger {
                lastRetryTrigger = commands.triggerRetry
                retry()
            }
            if commands.triggerCapture != lastCaptureTrigger {
                lastCaptureTrigger = commands.triggerCapture
                capture()
            }
            if commands.triggerClose != lastCloseTrigger {
                lastCloseTrigger = commands.triggerClose
                close()
            }
        }

        private func capture() {
            faceVC?.takePicture();
        }
        
        private func retry() {
           
        }

        private func close() {
            DispatchQueue.main.async {
                self.faceVC?.stopScanning()
                self.faceVC?.willMove(toParent: nil)
                self.faceVC?.view.removeFromSuperview()
                self.faceVC?.removeFromParent()
                self.faceVC = nil
            }
        }

        private func startFaceIfNeeded() {
            guard faceVC == nil else { return }

            guard let delegate else {
                assertionFailure("FaceMatchDelegate is nil")
                return
            }

            let stepId = flowController?
                .getCurrentStep()?
                .stepDefinition?
                .stepId

            guard let vc = assentifySdk?.startFaceMatch(
                faceMatchDelegate: delegate,
                secondImage: secondImage,
                showCountDown: true,
                stepId: stepId
            ) else {
                assertionFailure("startFaceMatch returned nil (sdk instance or config missing)")
                return
            }

            faceVC = vc
            addChild(vc)
            view.addSubview(vc.view)

            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.topAnchor.constraint(equalTo: view.topAnchor),
                vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            vc.didMove(toParent: self)
        }
    }
}
