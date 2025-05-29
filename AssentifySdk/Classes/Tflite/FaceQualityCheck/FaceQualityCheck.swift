
import UIKit
import MLKitFaceDetection
import MLKitVision

class FaceQualityCheck {
    
    private let faceDetector: FaceDetector
    
    init() {
        let options = FaceDetectorOptions()
        options.performanceMode = .fast
        options.landmarkMode = .all
        options.contourMode = .all
        self.faceDetector = FaceDetector.faceDetector(options: options)
    }
    
    func checkQuality(pixelBuffer: CVPixelBuffer, completion: @escaping (FaceEvents) -> Void) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let flippedCIImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))

        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(flippedCIImage, from: flippedCIImage.extent) else {
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
    
}
