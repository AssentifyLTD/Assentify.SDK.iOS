
import UIKit
import MLKitFaceDetection
import MLKitVision

class FaceQualityCheck {
    
    private let faceDetector: FaceDetector
    private let faceDetectorWink: FaceDetector
    
    init() {
        let options = FaceDetectorOptions()
        options.performanceMode = .fast
        options.landmarkMode = .all
        options.contourMode = .all
        self.faceDetector = FaceDetector.faceDetector(options: options)
        
        let optionsWink = FaceDetectorOptions()
        optionsWink.performanceMode = .fast
        optionsWink.landmarkMode = .all
        optionsWink.contourMode = .all
        optionsWink.classificationMode = .all
        self.faceDetectorWink = FaceDetector.faceDetector(options: optionsWink)
    }
    
    func checkQualityAction(pixelBuffer: CVPixelBuffer, completion: @escaping (FaceEvents) -> Void) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create flipped CGImage from CVPixelBuffer")
            return
        }

        let uiImage = UIImage(cgImage: cgImage)
        
        let visionImage = VisionImage(image: uiImage)

        
        faceDetector.process(visionImage) { faces, error in
            guard error == nil, let faces = faces, !faces.isEmpty else {
                completion(.NO_DETECT)
                return
            }
            
            var faceEvent: FaceEvents = .GOOD
            
            for face in faces {
                let leftEye = face.landmark(ofType: .leftEye)
                let rightEye = face.landmark(ofType: .rightEye)
                let nose = face.landmark(ofType: .noseBase)
                let mouthLeft = face.landmark(ofType: .mouthLeft)
                let mouthRight = face.landmark(ofType: .mouthRight)
                if leftEye != nil, rightEye != nil, nose != nil, mouthLeft != nil, mouthRight != nil {
                    
        
                    
                    /** Roll Check **/
                    if face.headEulerAngleZ > ConstantsValues.FaceCheckQualityThresholdPositive {
                        faceEvent = .ROLL_RIGHT
                    } else if face.headEulerAngleZ < ConstantsValues.FaceCheckQualityThresholdNegative {
                        faceEvent = .ROLL_LEFT
                    }
                    
                    /** Pitch Check **/
                    if face.headEulerAngleX > ConstantsValues.FaceCheckQualityThresholdNPositivePitch {
                        faceEvent = .PITCH_UP
                    } else if face.headEulerAngleX < ConstantsValues.FaceCheckQualityThresholdNegativePitch {
                        faceEvent = .PITCH_DOWN
                    }
                    
                    /** Yaw Check **/
                    if face.headEulerAngleY >  ConstantsValues.FaceCheckQualityThresholdPositive {
                        faceEvent = .YAW_RIGHT
                    } else if face.headEulerAngleY <  ConstantsValues.FaceCheckQualityThresholdNegative {
                        faceEvent = .YAW_LEFT
                    }
                    
                    completion(faceEvent)
                    return
                }
            }
            
            completion(.NO_DETECT)
        }
    }
    
    func checkQualityWinkAndBLINK(pixelBuffer: CVPixelBuffer, completion: @escaping (FaceEvents) -> Void) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let flippedCIImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))

        let context = CIContext()
        guard let cgImage = context.createCGImage(flippedCIImage, from: flippedCIImage.extent) else {
            print("Failed to create flipped CGImage from CVPixelBuffer")
            completion(.NO_DETECT)
            return
        }

        let uiImage = UIImage(cgImage: cgImage)
        let visionImage = VisionImage(image: uiImage)

        faceDetectorWink.process(visionImage) { faces, error in
            guard error == nil, let faces = faces, !faces.isEmpty else {
                completion(.NO_DETECT)
                return
            }

            for face in faces {
                let leftEyeOpen = face.leftEyeOpenProbability
                let rightEyeOpen = face.rightEyeOpenProbability
            
                let closedThreshold: CGFloat = 0.2
                let openThreshold: CGFloat = 0.8

                if leftEyeOpen < closedThreshold && rightEyeOpen < closedThreshold {
                    completion(.BLINK)
                    return
                } else if leftEyeOpen < closedThreshold && rightEyeOpen > openThreshold {
                    completion(.WINK_LEFT)
                    return
                } else if rightEyeOpen < closedThreshold && leftEyeOpen > openThreshold {
                    completion(.WINK_RIGHT)
                    return
                }
            }

            completion(.NO_DETECT)
        }
    }


    
}
