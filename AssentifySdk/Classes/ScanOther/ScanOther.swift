
import UIKit
import AVFoundation
import Accelerate
import CoreImage

public class ScanOther :UIViewController, CameraSetupDelegate , RemoteProcessingDelegate {
  
    
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
    

    private var scanOtherDelegate: ScanOtherDelegate?
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
         scanOtherDelegate:ScanOtherDelegate
    ) {
        self.configModel = configModel;
        self.environmentalConditions = environmentalConditions;
        self.apiKey = apiKey;
        self.processMrz = processMrz;
        self.performLivenessDetection = performLivenessDetection;
        self.saveCapturedVideoID = saveCapturedVideoID;
        self.storeCapturedDocument = storeCapturedDocument;
        self.storeImageStream = storeImageStream;
        self.scanOtherDelegate = scanOtherDelegate;
        
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
            sendingFlagsZoom.removeAll()
            sendingFlagsMotion.removeAll()
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
                        zoom = calculatePercentageChangeWidth(rect: rect2)
             
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
                sendingFlagsZoom.removeAll();
                sendingFlagsMotion.removeAll();
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
                    self.scanOtherDelegate?.onSend();
                    remoteProcessing?.starProcessing(
                        url: BaseUrls.signalRHub + HubConnectionFunctions.etHubConnectionFunction(blockType:BlockType.OTHER),
                         videoClip: convertPixelBufferToBase64(pixelBuffer: pixelBuffer)!,
                        stepDefinition: "IdentificationDocumentCapture",
                         appConfiguration:self.configModel!,
                         templateId: "",
                         secondImage: "",
                         connectionId: "ConnectionId",
                         clipsPath: "ClipsPath",
                         checkForFace: false,
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
        self.scanOtherDelegate?.onEnvironmentalConditionsChange(
                                                                  brightness: imageBrightnessChecker,
                                                                  motion: motion,zoom:zoom)
            
    }
    
    
     func onMessageReceived(eventName: String, remoteProcessingModel : RemoteProcessingModel ) {
        motionRectF.removeAll()
        sendingFlagsZoom.removeAll()
        sendingFlagsMotion.removeAll()
        if eventName == HubConnectionTargets.ON_COMPLETE {
            self.scanOtherDelegate?.onComplete(dataModel:remoteProcessingModel )
            start = false
        } else {
            start = eventName == HubConnectionTargets.ON_ERROR || eventName == HubConnectionTargets.ON_RETRY
        }
        
        switch eventName {
            case HubConnectionTargets.ON_ERROR:
                self.scanOtherDelegate?.onError(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_RETRY:
                self.scanOtherDelegate?.onRetry(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_CLIP_PREPARATION_COMPLETE:
                self.scanOtherDelegate?.onClipPreparationComplete(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_STATUS_UPDATE:
                self.scanOtherDelegate?.onStatusUpdated(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_UPDATE:
                self.scanOtherDelegate?.onUpdated(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_LIVENESS_UPDATE:
                self.scanOtherDelegate?.onLivenessUpdate(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_CARD_DETECTED:
                self.scanOtherDelegate?.onCardDetected(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_MRZ_EXTRACTED:
                self.scanOtherDelegate?.onMrzExtracted(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_MRZ_DETECTED:
                self.scanOtherDelegate?.onMrzDetected(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_NO_MRZ_EXTRACTED:
                self.scanOtherDelegate?.onNoMrzDetected(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_FACE_DETECTED:
                self.scanOtherDelegate?.onFaceDetected(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_NO_FACE_DETECTED:
                self.scanOtherDelegate?.onNoFaceDetected(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_FACE_EXTRACTED:
                self.scanOtherDelegate?.onFaceExtracted(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_QUALITY_CHECK_AVAILABLE:
                self.scanOtherDelegate?.onQualityCheckAvailable(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_DOCUMENT_CAPTURED:
                self.scanOtherDelegate?.onDocumentCaptured(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_DOCUMENT_CROPPED:
                self.scanOtherDelegate?.onDocumentCropped(dataModel:remoteProcessingModel )
            case HubConnectionTargets.ON_UPLOAD_FAILED:
                self.scanOtherDelegate?.onUploadFailed(dataModel:remoteProcessingModel )
            default:
                break
        }
    }

    
    func onVideCreated(videoBase64: String) {
    
    }
    
    func hasFaceOrCard() -> Bool {
        return  hasCard()
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


}
