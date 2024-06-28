
import Foundation



import UIKit
import AVFoundation
import Accelerate
import CoreImage

public class ScanIDCard :UIViewController, CameraSetupDelegate , RemoteProcessingDelegate {
    
    
    var guide : Guide = Guide();
    var previewView: PreviewView!
    var cameraFeedManager:CameraFeedManager!
    private let overlayView = OverlayView()
    private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    private let edgeOffset: CGFloat = 2.0
    private let labelOffset: CGFloat = 10.0
    private var modelDataHandler: ModelDataHandler? =
    ModelDataHandler(modelFileInfo: Yolov5.modelInfo, labelsFileInfo: Yolov5.labelsInfo,isFront: false)
    private var result: Result?
    var motionRectF: [CGRect] = []
    var sendingFlagsMotion: [MotionType] = []
    var sendingFlagsZoom: [ZoomType] = []
    var templateId: String?;
    let kycDocumentDetails: [KycDocumentDetails];
    var order = 0;
    
    
    private var scanIDCardDelegate: ScanIDCardDelegate?
    private var configModel: ConfigModel?
    private var environmentalConditions: EnvironmentalConditions?
    private var apiKey: String
    private var processMrz: Bool?
    private var performLivenessDetection: Bool?
    private var saveCapturedVideoID: Bool?
    private var storeCapturedDocument: Bool?
    private var storeImageStream: Bool?
    
    private var remoteProcessing: RemoteProcessing?
    private var motion:MotionType = MotionType.NO_DETECT;
    private var zoom:ZoomType = ZoomType.NO_DETECT;
    
    private var  start = true;
    init(configModel: ConfigModel!,
         environmentalConditions :EnvironmentalConditions,
         apiKey:String,
         processMrz:Bool,
         performLivenessDetection:Bool,
         saveCapturedVideoID:Bool,
         storeCapturedDocument:Bool,
         storeImageStream:Bool,
         scanIDCardDelegate:ScanIDCardDelegate,
           kycDocumentDetails:[KycDocumentDetails]
    ) {
        self.configModel = configModel;
        self.environmentalConditions = environmentalConditions;
        self.apiKey = apiKey;
        self.processMrz = processMrz;
        self.performLivenessDetection = performLivenessDetection;
        self.saveCapturedVideoID = saveCapturedVideoID;
        self.storeCapturedDocument = storeCapturedDocument;
        self.storeImageStream = storeImageStream;
        self.scanIDCardDelegate = scanIDCardDelegate;
        self.kycDocumentDetails = kycDocumentDetails;
        
       
        modelDataHandler?.customColor = environmentalConditions.CustomColor;
        
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
        self.previewView.backgroundColor = UIColor(white: 1, alpha: 1)
        view.addSubview(self.previewView)
        NSLayoutConstraint.activate([
            self.previewView.topAnchor.constraint(equalTo: view.topAnchor),
            self.previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        self.cameraFeedManager = CameraFeedManager(previewView: self.previewView,isFront: false)
        self.cameraFeedManager.checkCameraConfigurationAndStartSession()
        self.cameraFeedManager.delegate = self
        
        self.remoteProcessing = RemoteProcessing()
        
        if(!self.kycDocumentDetails.isEmpty){
           self.changeTemplateId(templateId: self.kycDocumentDetails[0].templateProcessingKeyInformation);
        }
        
        if(environmentalConditions!.enableGuide){
            self.guide.showCardGuide(view: self.view)
            self.guide.changeCardColor(view: self.view,to:self.environmentalConditions!.HoldHandColor)
        }
    }
    
    func didCaptureCVPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        runModel(onPixelBuffer: pixelBuffer)
        openCvCheck(pixelBuffer: pixelBuffer)
    }
    
    @objc func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {
        result = self.modelDataHandler?.runModel(onFrame: pixelBuffer)
        if (result?.inferences.count == 0) {
            motionRectF.removeAll()
            sendingFlagsMotion.removeAll()
            sendingFlagsZoom.removeAll()
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
            if(inference.className == "card"){
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
            
            let confidenceValue = Int(inference.confidence * 100.0)
            let string = "\(inference.className) (\(confidenceValue)%)"
            let size = string.size(usingFont: self.displayFont)
            let objectOverlay = ObjectOverlay(name: string, borderRect: convertedRect, nameStringSize: size, color: inference.displayColor, font: self.displayFont)
            objectOverlays.append(objectOverlay)
        }
        if(environmentalConditions!.enableDetect){
            self.draw(objectOverlays: objectOverlays)
        }
    }
    
    func draw(objectOverlays: [ObjectOverlay]) {
        self.overlayView.objectOverlays = objectOverlays
        self.overlayView.setNeedsDisplay()
        self.overlayView.frame = self.view.bounds
        self.overlayView.backgroundColor = UIColor.clear
        self.view.addSubview(self.overlayView)
        
    }
    
    
    func openCvCheck(pixelBuffer: CVPixelBuffer){
               
        let cropRect = CGRect(x: 0, y: 0, width: 256, height: 256)
        let imageBrightnessChecker = cropPixelBuffer(pixelBuffer, toRect: cropRect)!.brightness;
        if motionRectF.count >= 2 {
            let rect1 = motionRectF[motionRectF.count - 2]
            let rect2 = motionRectF[motionRectF.count - 1]
            motion = calculatePercentageChange(rect1: rect1, rect2: rect2)
            zoom = calculatePercentageChangeWidth(rect: rect1)
            
        }
        
        if (motion == MotionType.SENDING && zoom == ZoomType.SENDING) {
            modelDataHandler?.customColor = environmentalConditions!.CustomColor;
            sendingFlagsMotion.append(MotionType.SENDING);
            sendingFlagsZoom.append(ZoomType.SENDING);
            if(environmentalConditions!.enableGuide){
                DispatchQueue.main.async {
                    self.guide.changeCardColor(view: self.view,to:self.environmentalConditions!.CustomColor)
                }
            }
        } else {
            modelDataHandler?.customColor = environmentalConditions!.HoldHandColor;
            sendingFlagsMotion.removeAll();
            sendingFlagsZoom.removeAll();
            if(environmentalConditions!.enableGuide){
                DispatchQueue.main.async {
                    self.guide.changeCardColor(view: self.view,to:self.environmentalConditions!.HoldHandColor)
                }
            }
        }
        
        if (environmentalConditions!.checkConditions(
            brightness: imageBrightnessChecker)
            && motion == MotionType.SENDING  && zoom == ZoomType.SENDING) {
            if (start && sendingFlagsMotion.count > MotionLimit && sendingFlagsZoom.count > ZoomLimit) {
                if (hasFaceOrCard()) {
                    DispatchQueue.main.async {
                        self.scanIDCardDelegate?.onSend();
                    }
                    remoteProcessing?.starProcessing(
                        url: BaseUrls.signalRHub + HubConnectionFunctions.etHubConnectionFunction(blockType:BlockType.ID_CARD),
                        videoClip: convertPixelBufferToBase64(pixelBuffer: pixelBuffer)!,
                        stepDefinition: "IdentificationDocumentCapture",
                        appConfiguration:self.configModel!,
                        templateId: templateId!,
                        secondImage: "",
                        connectionId: "ConnectionId",
                        clipsPath: "ClipsPath",
                        checkForFace: hasFace(),
                        processMrz: processMrz!,
                        performLivenessDetection: performLivenessDetection!,
                        saveCapturedVideo: saveCapturedVideoID!,
                        storeCapturedDocument: storeCapturedDocument!,
                        isVideo: false,
                        storeImageStream: storeImageStream!
                    ) { result in
                        switch result {
                        case .success(let model):
                            self.onMessageReceived(eventName: model?.destinationEndpoint ?? "",remoteProcessingModel: model!)
                        case .failure(let error):
                            self.start = true;
                        }
                    }
                    start = false;
                }
            }
            
            
        }
        DispatchQueue.main.async {
            self.scanIDCardDelegate?.onEnvironmentalConditionsChange?(
                brightness: imageBrightnessChecker,
                motion: self.motion,zoom: self.zoom)
        }
        
    }
    
    
    private func changeTemplateId( templateId:String) {
        DispatchQueue.main.async {
            self.motionRectF.removeAll()
            self.sendingFlagsMotion.removeAll()
            self.sendingFlagsZoom.removeAll()
            self.start = true;
            self.templateId = templateId;
        }
    }
    
    func onMessageReceived(eventName: String, remoteProcessingModel : RemoteProcessingModel ) {
        DispatchQueue.main.async {
            self.motionRectF.removeAll()
            self.sendingFlagsMotion.removeAll()
            self.sendingFlagsZoom.removeAll()
            if eventName == HubConnectionTargets.ON_COMPLETE {
                
                var iDExtractedModel = IDExtractedModel.fromJsonString(responseString:remoteProcessingModel.response!);
                var iDResponseModel = IDResponseModel(
                    destinationEndpoint: remoteProcessingModel.destinationEndpoint,
                    iDExtractedModel: iDExtractedModel,
                    error: remoteProcessingModel.error,
                    success: remoteProcessingModel.success
                )
                self.scanIDCardDelegate?.onComplete(dataModel:iDResponseModel,order:self.order )
                self.order =   self.order + 1;
                if(!self.kycDocumentDetails.isEmpty && self.order < self.kycDocumentDetails.count){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.changeTemplateId(templateId: self.kycDocumentDetails[  self.order].templateProcessingKeyInformation);
                    }
                    
                }else{
                    self.start = false
                }
                
            } else {
                self.start = eventName == HubConnectionTargets.ON_WRONG_TEMPLATE || eventName == HubConnectionTargets.ON_ERROR || eventName == HubConnectionTargets.ON_RETRY
            }
            
            switch eventName {
            case HubConnectionTargets.ON_ERROR:
                self.scanIDCardDelegate?.onError(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_RETRY:
                self.scanIDCardDelegate?.onRetry(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_CLIP_PREPARATION_COMPLETE:
                self.scanIDCardDelegate?.onClipPreparationComplete?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_STATUS_UPDATE:
                self.scanIDCardDelegate?.onStatusUpdated?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_UPDATE:
                self.scanIDCardDelegate?.onUpdated?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_LIVENESS_UPDATE:
                self.scanIDCardDelegate?.onLivenessUpdate?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_CARD_DETECTED:
                self.scanIDCardDelegate?.onCardDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_MRZ_EXTRACTED:
                self.scanIDCardDelegate?.onMrzExtracted?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_MRZ_DETECTED:
                self.scanIDCardDelegate?.onMrzDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_NO_MRZ_EXTRACTED:
                self.scanIDCardDelegate?.onNoMrzDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_FACE_DETECTED:
                self.scanIDCardDelegate?.onFaceDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_NO_FACE_DETECTED:
                self.scanIDCardDelegate?.onNoFaceDetected?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_FACE_EXTRACTED:
                self.scanIDCardDelegate?.onFaceExtracted?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_QUALITY_CHECK_AVAILABLE:
                self.scanIDCardDelegate?.onQualityCheckAvailable?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_DOCUMENT_CAPTURED:
                self.scanIDCardDelegate?.onDocumentCaptured?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_DOCUMENT_CROPPED:
                self.scanIDCardDelegate?.onDocumentCropped?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_UPLOAD_FAILED:
                self.scanIDCardDelegate?.onUploadFailed?(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_WRONG_TEMPLATE:
                self.scanIDCardDelegate?.onWrongTemplate(dataModel:remoteProcessingModel )
            default:
                break
            }
        }
    }
    
    
    func onVideCreated(videoBase64: String) {
        
    }
    
    func hasFaceOrCard() -> Bool {
        return hasFace() || hasCard()
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
    
    func hasCard() -> Bool {
        var hasCard = false
        for item in result!.inferences {
            if item.className == "card"  && environmentalConditions!.isPredictionValid(confidence: item.confidence) {
                hasCard = true
                break
            }
        }
        return hasCard
    }
    
    
    
    
    
    
}
