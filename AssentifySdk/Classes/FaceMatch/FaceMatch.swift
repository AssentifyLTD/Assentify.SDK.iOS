

import Foundation
import UIKit
import AVFoundation
import Accelerate
import CoreImage

public class FaceMatch :UIViewController, CameraSetupDelegate , RemoteProcessingDelegate {
    
    
    var checkLiveness :CheckLiveness = CheckLiveness();
    var guide : Guide = Guide();
    var countdownLabel : UIView?;
    var countdownTimer: Timer?
    var previewView: PreviewView!
    var cameraFeedManager:CameraFeedManager!
    private let overlayView = OverlayView()
    private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    private let edgeOffset: CGFloat = 2.0
    private let labelOffset: CGFloat = 10.0
    private var modelDataHandler: ModelDataHandler? =
    ModelDataHandler(modelFileInfo: Yolov5.modelInfo, labelsFileInfo: Yolov5.labelsInfo,isFront: true)
    private var result: Result?
    var motionRectF: [CGRect] = []
    var sendingFlags: [MotionType] = []
    var sendingFlagsZoom: [ZoomType] = []
    var livenessCheckArray: [CVPixelBuffer] = []
    var livenessTypeResults: [LivenessType] = []
    
    private var faceMatchDelegate: FaceMatchDelegate?
    private var configModel: ConfigModel?
    private var environmentalConditions: EnvironmentalConditions?
    private var apiKey: String
    private var processMrz: Bool?
    private var performLivenessDocument: Bool?
    private var performLivenessFace: Bool?
    private var saveCapturedVideoID: Bool?
    private var storeCapturedDocument: Bool?
    private var storeImageStream: Bool?
    private var secondImage: String?
    
    private var remoteProcessing: RemoteProcessing?
    private var motion:MotionType = MotionType.NO_DETECT;
    private var zoom:ZoomType = ZoomType.NO_DETECT;
    private var livenessType:LivenessType = LivenessType.NON;
    
    private var detectIfRectFInsideTheScreen = DetectIfRectInsideTheScreen();
    private var isRectFInsideTheScreen:Bool = false;
    private var showCountDown:Bool = true;
    private var isCountDownStarted:Bool = true;
    private var  start = true;
    private var  localLivenessLimit = 0;
    private var faceQualityCheck = FaceQualityCheck()
    private var faceEvent = FaceEvents.NO_DETECT;
    
    init(configModel: ConfigModel!,
         environmentalConditions :EnvironmentalConditions,
         apiKey:String,
         processMrz:Bool,
         performLivenessDocument:Bool,
         performLivenessFace:Bool,
         saveCapturedVideoID:Bool,
         storeCapturedDocument:Bool,
         storeImageStream:Bool,
         faceMatchDelegate:FaceMatchDelegate,
         secondImage:String,
         showCountDown:Bool
    ) {
        self.configModel = configModel;
        self.environmentalConditions = environmentalConditions;
        self.apiKey = apiKey;
        self.processMrz = processMrz;
        self.performLivenessDocument = performLivenessDocument;
        self.performLivenessFace = performLivenessFace;
        self.saveCapturedVideoID = saveCapturedVideoID;
        self.storeCapturedDocument = storeCapturedDocument;
        self.storeImageStream = storeImageStream;
        self.faceMatchDelegate = faceMatchDelegate;
        self.secondImage = secondImage;
        self.showCountDown = showCountDown;
        
        modelDataHandler?.customColor = ConstantsValues.DetectColor;
        
        if(performLivenessFace){
            localLivenessLimit = 12;
        }else{
            localLivenessLimit = 0;
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        
        
        
        guard modelDataHandler != nil else {
            fatalError("Failed to load model")
        }
        overlayView.clearsContextBeforeDrawing = true
        self.previewView = PreviewView();
        self.previewView.translatesAutoresizingMaskIntoConstraints = false
        self.previewView.contentMode = .scaleToFill
        view.addSubview(self.previewView)
        NSLayoutConstraint.activate([
            self.previewView.topAnchor.constraint(equalTo: view.topAnchor),
            self.previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        self.cameraFeedManager = CameraFeedManager(previewView: self.previewView,isFront: true)
        self.cameraFeedManager.checkCameraConfigurationAndStartSession()
        self.cameraFeedManager.delegate = self
        
        self.remoteProcessing = RemoteProcessing()
        
        if(environmentalConditions!.enableGuide){
            if(self.guide.faceSvgImageView == nil){
               self.guide.showFaceGuide(view: self.view)
            }
             self.guide.changeFaceColor(view: self.view,to:self.environmentalConditions!.HoldHandColor,notTransmitting: self.start)
        }
        
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    public  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    public  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    public   override var shouldAutorotate: Bool {
        return false
    }
    
    
    func didCaptureCVPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        runModel(onPixelBuffer: pixelBuffer)
        openCvCheck(pixelBuffer: pixelBuffer)
        let cropRect = CGRect(x: 0, y: 0, width: 256, height: 256)
        let imageBrightnessChecker = cropPixelBuffer(pixelBuffer, toRect: cropRect)!.brightness;
        if motionRectF.count >= 2 {
            let rect1 = motionRectF[motionRectF.count - 2]
            let rect2 = motionRectF[motionRectF.count - 1]
            motion = calculatePercentageChange(rect1: rect1, rect2: rect2)
            zoom = calculatePercentageChangeWidth(rect: rect2)
        }
        
        DispatchQueue.main.async {
            self.faceMatchDelegate?.onEnvironmentalConditionsChange?(
                brightnessEvents:self.environmentalConditions!.checkConditions(
                    brightness: imageBrightnessChecker),
                motion: self.motion,faceEvents:!self.start ? FaceEvents.GOOD : self.faceEvent,zoom: self.zoom)
        }
    }
    
    
    @objc func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {
        result = self.modelDataHandler?.runModel(onFrame: pixelBuffer)
        if (result?.inferences.count == 0) {
            motionRectF.removeAll()
            sendingFlagsZoom.removeAll()
            sendingFlags.removeAll()
            motion = MotionType.NO_DETECT;
            zoom = ZoomType.NO_DETECT;
        }
        guard let displayResult = result else {
            return
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        DispatchQueue.main.async {
            self.drawAfterPerformingCalculations(onInferences: displayResult.inferences, withImageSize: CGSize(width: CGFloat(width), height: CGFloat(height)))
        }
    }
    func drawAfterPerformingCalculations(onInferences inferences: [Inference], withImageSize imageSize:CGSize) {
        self.overlayView.objectOverlays = []
        self.overlayView.setNeedsDisplay()
        var objectOverlays: [ObjectOverlay] = []
        for inference in inferences {
            if(inference.className == "face"){
                motionRectF.append(inference.rect);
            }
            
            var convertedRect = inference.rect.applying(CGAffineTransform(scaleX: self.overlayView.bounds.size.width / imageSize.width, y: self.overlayView.bounds.size.height / imageSize.height))
            if convertedRect.origin.x < 0 {
                convertedRect.origin.x = self.edgeOffset
            }
            if convertedRect.origin.y < 0 {
                convertedRect.origin.y = self.edgeOffset
            }
            if convertedRect.maxY > self.overlayView.bounds.maxY {
                convertedRect.size.height = self.overlayView.bounds.maxY - convertedRect.origin.y - self.edgeOffset
            }
            if convertedRect.maxX > self.overlayView.bounds.maxX {
                convertedRect.size.width = self.overlayView.bounds.maxX - convertedRect.origin.x - self.edgeOffset
            }
            
            if(inference.className == "face"){
                isRectFInsideTheScreen = detectIfRectFInsideTheScreen.isRectWithinMargins(rect: convertedRect);
            }
            
            let confidenceValue = Int(inference.confidence * 100.0)
            let string = "\(inference.className) (\(confidenceValue)%)"
            let size = string.size(usingFont: self.displayFont)
            let objectOverlay = ObjectOverlay(name: string, borderRect: convertedRect, nameStringSize: size, color: inference.displayColor, font: self.displayFont)
            objectOverlays.append(objectOverlay)
        }
        self.draw(objectOverlays: objectOverlays)
        
    }
    
    func draw(objectOverlays: [ObjectOverlay]) {
        self.overlayView.objectOverlays = objectOverlays
        self.overlayView.setNeedsDisplay()
        self.overlayView.frame = self.view.bounds
        self.overlayView.backgroundColor = UIColor.clear
        if(environmentalConditions!.enableDetect && start){
            self.view.addSubview(self.overlayView)
        }else{
            self.overlayView.removeFromSuperview()
        }
        
    }
    
    
    func openCvCheck(pixelBuffer: CVPixelBuffer){
        let cropRect = CGRect(x: 0, y: 0, width: 256, height: 256)
        let cropPixelBuffer = cropPixelBuffer(pixelBuffer, toRect: cropRect)!;
        if motionRectF.count >= 2 {
            let rect1 = motionRectF[motionRectF.count - 2]
            let rect2 = motionRectF[motionRectF.count - 1]
            motion = calculatePercentageChange(rect1: rect1, rect2: rect2)
            zoom = calculatePercentageChangeWidth(rect: rect2)
        }
        if let downscaledBuffer = downscalePixelBuffer(pixelBuffer, scaleFactor: 0.3) {
            faceQualityCheck.checkQuality(pixelBuffer: downscaledBuffer) { faceEvent in
                self.faceEvent = faceEvent
            }
        }
        if (motion == MotionType.SENDING && zoom == ZoomType.SENDING  && isRectFInsideTheScreen && environmentalConditions!.checkConditions(
            brightness: cropPixelBuffer.brightness) == BrightnessEvents.Good && self.faceEvent == FaceEvents.GOOD) {
            modelDataHandler?.customColor = ConstantsValues.DetectColor;
            sendingFlags.append(MotionType.SENDING);
            sendingFlagsZoom.append(ZoomType.SENDING);
            if(self.performLivenessFace!){
                if(livenessCheckArray.count < self.localLivenessLimit){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.livenessCheckArray.append(pixelBuffer)
                    }
                    if (self.checkLiveness.preprocessAndPredict(pixelBuffer:pixelBuffer) == LivenessType.LIVE){
                        self.livenessTypeResults.append(LivenessType.LIVE)
                     }
                }
            }
            if(environmentalConditions!.enableGuide){
                DispatchQueue.main.async {
                    if(self.guide.faceSvgImageView == nil){
                        self.guide.showFaceGuide(view: self.view)
                    }
                    self.guide.changeFaceColor(view: self.view,to:ConstantsValues.DetectColor,notTransmitting: self.start)
                }
            }
        } else {
            modelDataHandler?.customColor = environmentalConditions!.HoldHandColor;
            sendingFlags.removeAll();
            sendingFlagsZoom.removeAll();
            livenessCheckArray.removeAll();
            livenessTypeResults.removeAll();
            if(environmentalConditions!.enableGuide){
                DispatchQueue.main.async {
                    if(self.guide.faceSvgImageView == nil){
                        self.guide.showFaceGuide(view: self.view)
                    }
                    self.guide.changeFaceColor(view: self.view,to:self.environmentalConditions!.HoldHandColor,notTransmitting: self.start)
                }
            }
        }
      
        if (self.showCountDown ) {
            if (!hasFaceOrCard() || !isRectFInsideTheScreen ||  self.faceEvent != FaceEvents.GOOD) {
                DispatchQueue.main.async {
                    self.countdownLabel?.removeFromSuperview();
                    self.countdownTimer?.invalidate();
                    self.isCountDownStarted = true;
                }
            }
         }
        
        if (environmentalConditions!.checkConditions(
            brightness: cropPixelBuffer.brightness) == BrightnessEvents.Good
            && motion == MotionType.SENDING && zoom == ZoomType.SENDING  && isRectFInsideTheScreen && self.faceEvent == FaceEvents.GOOD) {
            if (start && sendingFlags.count > MotionLimitFace && sendingFlagsZoom.count > FaceZoomLimit && livenessCheckArray.count == self.localLivenessLimit ) {
                if (hasFaceOrCard()) {
                    if(self.start){
                        if(self.showCountDown){
                            if(self.isCountDownStarted){
                                self.isCountDownStarted = false;
                                DispatchQueue.main.async {
                                       (self.countdownLabel, self.countdownTimer) = self.guide.showFaceTimer(view: self.view, initialTextColorHex:self.environmentalConditions!.HoldHandColor) {
                                        self.isCountDownStarted = true;
                                        self.start = false;
                                        self.faceMatchDelegate?.onSend();
                                        self.livenessType = LivenessType.NOT_LIVE;
                                           if(self.performLivenessFace!){
                                               if Double(self.livenessTypeResults.count) / Double(self.livenessCheckArray.count) > ConstantsValues.LIVENESS_THRESHOLD {
                                                   self.livenessType = LivenessType.LIVE
                                               } else {
                                                   self.livenessType = LivenessType.NOT_LIVE
                                               }
                                           }else{
                                               self.livenessType = LivenessType.LIVE
                                           }
                                           let converter = ParallelImageProcessing()
                                           converter.setPixelBuffers(self.livenessCheckArray)
                                           converter.convertBuffers {
                                               if(self.livenessType == LivenessType.LIVE){
                                                      self.remoteProcessing?.starProcessing(
                                                       url: BaseUrls.signalRHub +  HubConnectionFunctions.etHubConnectionFunction(blockType:BlockType.FACE_MATCH),
                                                       videoClip: "",
                                                       stepDefinition: "FaceImageAcquisition",
                                                       appConfiguration:self.configModel!,
                                                       templateId: "",
                                                       secondImage: self.secondImage!,
                                                       connectionId: "ConnectionId",
                                                       clipsPath: "ClipsPath",
                                                       checkForFace: true,
                                                       processMrz: self.processMrz!,
                                                       performLivenessDocument:self.performLivenessDocument!,
                                                       performLivenessFace: self.performLivenessFace!,
                                                       saveCapturedVideo: self.saveCapturedVideoID!,
                                                       storeCapturedDocument: self.storeCapturedDocument!,
                                                       isVideo: true,
                                                       storeImageStream: self.storeImageStream!,
                                                       selfieImage: convertPixelBufferToBase64(pixelBuffer: pixelBuffer)!,
                                                       clips:converter.getClips()
                                                      ) { result in
                                                          switch result {
                                                          case .success(let model):
                                                              self.onMessageReceived(eventName: model?.destinationEndpoint ?? "",remoteProcessingModel: model!)
                                                          case .failure(let error):
                                                              self.start = true;
                                                              self.onMessageReceived(eventName: HubConnectionTargets.ON_ERROR ,remoteProcessingModel: RemoteProcessingModel(
                                                               destinationEndpoint: HubConnectionTargets.ON_ERROR,
                                                               response: "",
                                                               error: "",
                                                               success: false
                                                              ))
                                                          }
                                                      }}else{
                                                          self.onMessageReceived(eventName: HubConnectionTargets.ON_LIVENESS_UPDATE ,remoteProcessingModel: RemoteProcessingModel(
                                                              destinationEndpoint: HubConnectionTargets.ON_LIVENESS_UPDATE,
                                                              response: "",
                                                              error: "",
                                                              success: false
                                                           ))
                                                     }
                                           }
                                           
                                      
                                    }
                                }
                            }
                        }else
                        {
                            self.start = false;
                            self.faceMatchDelegate?.onSend();
                            livenessType = LivenessType.NOT_LIVE;
                            if(self.performLivenessFace!){
                                if Double(self.livenessTypeResults.count) / Double(self.livenessCheckArray.count) > ConstantsValues.LIVENESS_THRESHOLD {
                                    self.livenessType = LivenessType.LIVE
                                } else {
                                    self.livenessType = LivenessType.NOT_LIVE
                                }
                            }else{
                                self.livenessType = LivenessType.LIVE
                            }
                            let converter = ParallelImageProcessing()
                            converter.setPixelBuffers(self.livenessCheckArray)
                            converter.convertBuffers {
                              if(self.livenessType == LivenessType.LIVE){
                                self.remoteProcessing?.starProcessing(
                                    url: BaseUrls.signalRHub +  HubConnectionFunctions.etHubConnectionFunction(blockType:BlockType.FACE_MATCH),
                                    videoClip: "",
                                    stepDefinition: "FaceImageAcquisition",
                                    appConfiguration:self.configModel!,
                                    templateId: "",
                                    secondImage: self.secondImage!,
                                    connectionId: "ConnectionId",
                                    clipsPath: "ClipsPath",
                                    checkForFace: true,
                                    processMrz: self.processMrz!,
                                    performLivenessDocument:self.performLivenessDocument!,
                                    performLivenessFace: self.performLivenessFace!,
                                    saveCapturedVideo: self.saveCapturedVideoID!,
                                    storeCapturedDocument: self.storeCapturedDocument!,
                                    isVideo: true,
                                    storeImageStream: self.storeImageStream!,
                                    selfieImage: convertPixelBufferToBase64(pixelBuffer: pixelBuffer)!,
                                    clips:converter.getClips()
                                ) { result in
                                    switch result {
                                    case .success(let model):
                                        self.onMessageReceived(eventName: model?.destinationEndpoint ?? "",remoteProcessingModel: model!)
                                    case .failure(let error):
                                        self.start = true;
                                        self.onMessageReceived(eventName: HubConnectionTargets.ON_ERROR ,remoteProcessingModel: RemoteProcessingModel(
                                            destinationEndpoint: HubConnectionTargets.ON_ERROR,
                                            response: "",
                                            error: "",
                                            success: false
                                        ))
                                    }
                                }
                                
                            }else{
                                self.onMessageReceived(eventName: HubConnectionTargets.ON_LIVENESS_UPDATE ,remoteProcessingModel: RemoteProcessingModel(
                                    destinationEndpoint: HubConnectionTargets.ON_LIVENESS_UPDATE,
                                    response: "",
                                    error: "",
                                    success: false
                                ))
                            }
                        }
                            
                        }
                        
                    }
                    
                    
                    
                }
            }
            
            
        }
        
        
    }
    
    
    
    
    func onMessageReceived(eventName: String, remoteProcessingModel : RemoteProcessingModel ) {
        DispatchQueue.main.async {
            self.motionRectF.removeAll()
            self.sendingFlags.removeAll()
            self.sendingFlagsZoom.removeAll()
            self.livenessCheckArray.removeAll();
            self.livenessTypeResults.removeAll();
            if eventName == HubConnectionTargets.ON_COMPLETE {
                var faceExtractedModel = FaceExtractedModel.fromJsonString(responseString:remoteProcessingModel.response!);
                var faceResponseModel = FaceResponseModel(
                    destinationEndpoint: remoteProcessingModel.destinationEndpoint,
                    faceExtractedModel: faceExtractedModel,
                    error: remoteProcessingModel.error,
                    success: remoteProcessingModel.success
                )
                self.faceMatchDelegate?.onComplete(dataModel:faceResponseModel )
                self.start = false
            } else {
                self.start = eventName == HubConnectionTargets.ON_ERROR || eventName == HubConnectionTargets.ON_RETRY ||  eventName == HubConnectionTargets.ON_LIVENESS_UPDATE
            }
            
            switch eventName {
            case HubConnectionTargets.ON_ERROR:
                self.faceMatchDelegate?.onError(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_RETRY:
                self.faceMatchDelegate?.onRetry(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_CLIP_PREPARATION_COMPLETE:
                self.faceMatchDelegate?.onClipPreparationComplete?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_STATUS_UPDATE:
                self.faceMatchDelegate?.onStatusUpdated?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_UPDATE:
                self.faceMatchDelegate?.onUpdated?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_LIVENESS_UPDATE:
                self.faceMatchDelegate?.onLivenessUpdate?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_CARD_DETECTED:
                self.faceMatchDelegate?.onCardDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_MRZ_EXTRACTED:
                self.faceMatchDelegate?.onMrzExtracted?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_MRZ_DETECTED:
                self.faceMatchDelegate?.onMrzDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_NO_MRZ_EXTRACTED:
                self.faceMatchDelegate?.onNoMrzDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_FACE_DETECTED:
                self.faceMatchDelegate?.onFaceDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_NO_FACE_DETECTED:
                self.faceMatchDelegate?.onNoFaceDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_FACE_EXTRACTED:
                self.faceMatchDelegate?.onFaceExtracted?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_QUALITY_CHECK_AVAILABLE:
                self.faceMatchDelegate?.onQualityCheckAvailable?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_DOCUMENT_CAPTURED:
                self.faceMatchDelegate?.onDocumentCaptured?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_DOCUMENT_CROPPED:
                self.faceMatchDelegate?.onDocumentCropped?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_UPLOAD_FAILED:
                self.faceMatchDelegate?.onUploadFailed?(dataModel:remoteProcessingModel )
            default:
                break
            }
        }
    }
    
    
    func onVideCreated(videoBase64: String) {
        
    }
    
    func hasFaceOrCard() -> Bool {
        return hasFace()
    }
    
    func hasFace() -> Bool {
        var hasFace = false
        for item in result!.inferences {
            if item.className == "face" && environmentalConditions!.isPredictionValid(confidence: item.confidence) {
                hasFace = true
                break
            }
        }
        return hasFace
    }
    
    
    
    
    func filterBySourceCountryCode(dataList: [Templates]) -> [Templates] {
        var filteredList = [Templates]()
        var uniqueSourceCountryCodes = [String]()
        
        for data in dataList {
            if !uniqueSourceCountryCodes.contains(data.sourceCountryCode) {
                filteredList.append(data)
                uniqueSourceCountryCodes.append(data.sourceCountryCode)
            }
            
        }
        return filteredList
    }
    
    func filterTemplatesCountryCode(dataList: [Templates], countryCode: String) -> [Templates] {
        var filteredList = [Templates]()
        
        for data in dataList {
            if data.sourceCountryCode == countryCode {
                filteredList.append(data)
            }
        }
        return filteredList
    }
    
    
    
    enum ResultVideo<Success, Failure: Error> {
        case success(Success)
        case failure(Failure)
    }
    
    
    func createVideoFromPixelBuffers(pixelBuffers: [CVPixelBuffer], outputURL: URL, size: CGSize, videoFrameRate: Int, completion: @escaping (ResultVideo<String, Error>) -> Void) {
        
        let compressionProperties: [String: Any] = [
            AVVideoAverageBitRateKey: 2500000,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
        ]
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height,
            AVVideoCompressionPropertiesKey: compressionProperties
            
        ]
        
        // Initialize AVAssetWriter
        guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error creating asset writer"])))
            return
        }
        
        // Initialize video input
        let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput.expectsMediaDataInRealTime = false
        
        // Add input to asset writer
        guard assetWriter.canAdd(videoInput) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot add video input to asset writer"])))
            return
        }
        assetWriter.add(videoInput)
        
        // Initialize pixel buffer adaptor
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: nil)
        
        // Start writing
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: .zero)
        
        // Calculate frame duration
        let frameDuration = CMTimeMake(value: 1, timescale: Int32(videoFrameRate))
        var frameTime = CMTime.zero
        
        // Append pixel buffers
        for pixelBuffer in pixelBuffers {
            while !videoInput.isReadyForMoreMediaData {}
            
            let presentationTime = CMTimeAdd(frameTime, frameDuration)
            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
            
            frameTime = CMTimeAdd(frameTime, frameDuration)
        }
        
        // Finish writing
        videoInput.markAsFinished()
        assetWriter.finishWriting {
            if let error = assetWriter.error {
                completion(.failure(error))
            } else {
                // Convert video file to base64
                do {
                    let videoData = try Data(contentsOf: outputURL)
                    let base64String = videoData.base64EncodedString()
                    completion(.success(base64String))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getSizeFromFirstPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> CGSize {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    func createTemporaryFileURL() -> URL? {
        do {
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
            let uniqueFilename = ProcessInfo.processInfo.globallyUniqueString + ".mp4"
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(uniqueFilename)
            return temporaryFileURL
        } catch {
            return nil
        }
    }
    
   
    
}
