

import Foundation
import UIKit
import AVFoundation
import Accelerate
import CoreImage

public class FaceMatch :UIViewController, CameraSetupDelegate , RemoteProcessingDelegate {
  
    
    var guide : Guide = Guide();
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
    var pixelBuffers: [CVPixelBuffer] = []

    private var faceMatchDelegate: FaceMatchDelegate?
    private var configModel: ConfigModel?
    private var environmentalConditions: EnvironmentalConditions?
    private var apiKey: String
    private var processMrz: Bool?
    private var performLivenessDetection: Bool?
    private var saveCapturedVideoID: Bool?
    private var storeCapturedDocument: Bool?
    private var storeImageStream: Bool?
    private var secondImage: String?
    
    private var remoteProcessing: RemoteProcessing?
    private var motion:MotionType = MotionType.NO_DETECT;

    private var  start = true;
    init(configModel: ConfigModel!,
         environmentalConditions :EnvironmentalConditions,
         apiKey:String,
         processMrz:Bool,
         performLivenessDetection:Bool,
         saveCapturedVideoID:Bool,
         storeCapturedDocument:Bool,
         storeImageStream:Bool,
         faceMatchDelegate:FaceMatchDelegate,
         secondImage:String
    ) {
        self.configModel = configModel;
        self.environmentalConditions = environmentalConditions;
        self.apiKey = apiKey;
        self.processMrz = processMrz;
        self.performLivenessDetection = performLivenessDetection;
        self.saveCapturedVideoID = saveCapturedVideoID;
        self.storeCapturedDocument = storeCapturedDocument;
        self.storeImageStream = storeImageStream;
        self.faceMatchDelegate = faceMatchDelegate;
        self.secondImage = secondImage;
        
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
     

      self.cameraFeedManager = CameraFeedManager(previewView: self.previewView,isFront: true)
      self.cameraFeedManager.checkCameraConfigurationAndStartSession()
      self.cameraFeedManager.delegate = self
        
      self.remoteProcessing = RemoteProcessing()
    
        if(environmentalConditions!.enableGuide){
            self.guide.showFaceGuide(view: self.view)
            self.guide.changeFaceColor(view: self.view,to:self.environmentalConditions!.HoldHandColor)
        }
    }
    
    func didCaptureCVPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        if( self.pixelBuffers.count < 10){
            self.pixelBuffers.append(pixelBuffer)
        }
        runModel(onPixelBuffer: pixelBuffer)
        openCvCheck(pixelBuffer: pixelBuffer)
    }
    
    @objc func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {
        result = self.modelDataHandler?.runModel(onFrame: pixelBuffer)
        if (result?.inferences.count == 0) {
            motionRectF.removeAll()
            sendingFlags.removeAll()
            motion = MotionType.NO_DETECT;
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
             
      }
        
        if (motion == MotionType.SENDING) {
              modelDataHandler?.customColor = environmentalConditions!.CustomColor;
            sendingFlags.append(MotionType.SENDING);
            if(environmentalConditions!.enableGuide){
                DispatchQueue.main.async {
                    self.guide.changeFaceColor(view: self.view,to:self.environmentalConditions!.CustomColor)
                }
            }
            } else {
                modelDataHandler?.customColor = environmentalConditions!.HoldHandColor;
                sendingFlags.removeAll();
                if(environmentalConditions!.enableGuide){
                    DispatchQueue.main.async {
                        self.guide.changeFaceColor(view: self.view,to:self.environmentalConditions!.HoldHandColor)
                    }
                }
         }
    
        if (environmentalConditions!.checkConditions(
                                                     brightness: imageBrightnessChecker)
                     && motion == MotionType.SENDING) {
            if (start && sendingFlags.count > MotionLimit && self.pixelBuffers.count  == 10 ) {
                if (hasFaceOrCard()) {
                     let outputURL: URL = self.createTemporaryFileURL()!
                        guard let firstPixelBuffer = self.pixelBuffers.first else {
                            return
                        }
                        let videoSize = self.getSizeFromFirstPixelBuffer(firstPixelBuffer)
                        let frameRate = 30;
                        self.createVideoFromPixelBuffers(pixelBuffers: self.pixelBuffers, outputURL: outputURL, size: videoSize, videoFrameRate: frameRate) { result in
                            switch result {
                            case .success(let base64String):   
                                if(self.start){
                                    self.pixelBuffers.removeAll();
                                    DispatchQueue.main.async {
                                        self.faceMatchDelegate?.onSend();
                                    }
                                    self.remoteProcessing?.starProcessing(
                                        url: BaseUrls.signalRHub +  HubConnectionFunctions.etHubConnectionFunction(blockType:BlockType.FACE_MATCH),
                                         videoClip: base64String,
                                        stepDefinition: "FaceImageAcquisition",
                                         appConfiguration:self.configModel!,
                                         templateId: "",
                                         secondImage: self.secondImage!,
                                         connectionId: "ConnectionId",
                                         clipsPath: "ClipsPath",
                                         checkForFace: true,
                                        processMrz: self.processMrz!,
                                        performLivenessDetection: self.performLivenessDetection!,
                                        saveCapturedVideo: self.saveCapturedVideoID!,
                                        storeCapturedDocument: self.storeCapturedDocument!,
                                         isVideo: true,
                                        storeImageStream: self.storeImageStream!
                                         ) { result in
                                        switch result {
                                        case .success(let model):
                                            self.onMessageReceived(eventName: model?.destinationEndpoint ?? "",remoteProcessingModel: model!)
                                        case .failure(let error):
                                            self.start = true;
                                        }
                                    }
                                    self.start = false;
                                }
                                
                            case .failure(let error):
                                self.pixelBuffers.removeAll();
                            }
                        }
                }
            }
          
            
        }
        DispatchQueue.main.async {
            self.faceMatchDelegate?.onEnvironmentalConditionsChange?(
                brightness: imageBrightnessChecker,
                motion: self.motion)
        }
            
    }
    
    

    
     func onMessageReceived(eventName: String, remoteProcessingModel : RemoteProcessingModel ) {
         DispatchQueue.main.async {
             self.motionRectF.removeAll()
             self.sendingFlags.removeAll()
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
                 self.start = eventName == HubConnectionTargets.ON_ERROR || eventName == HubConnectionTargets.ON_RETRY
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
