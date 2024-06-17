

import Foundation



public class EnvironmentalConditions {


    /**Detect**/
    var enableDetect: Bool
      var enableGuide: Bool
        
    // BRIGHTNESS
    var BRIGHTNESS_HIGH_THRESHOLD: Float
    var BRIGHTNESS_LOW_THRESHOLD: Float

    // PREDICTION
    var PREDICTION_LOW_PERCENTAGE: Float
    var PREDICTION_HIGH_PERCENTAGE: Float

    var CustomColor: String
    var HoldHandColor: String



    public  init(
        enableDetect: Bool,
        enableGuide: Bool,
        BRIGHTNESS_HIGH_THRESHOLD: Float,
        BRIGHTNESS_LOW_THRESHOLD: Float,
        PREDICTION_LOW_PERCENTAGE: Float,
        PREDICTION_HIGH_PERCENTAGE: Float,
        CustomColor: String,
        HoldHandColor: String
    ) {
        self.enableDetect = enableDetect
        self.enableGuide = enableGuide
        self.BRIGHTNESS_HIGH_THRESHOLD = BRIGHTNESS_HIGH_THRESHOLD
        self.BRIGHTNESS_LOW_THRESHOLD = BRIGHTNESS_LOW_THRESHOLD
        self.PREDICTION_LOW_PERCENTAGE = PREDICTION_LOW_PERCENTAGE
        self.PREDICTION_HIGH_PERCENTAGE = PREDICTION_HIGH_PERCENTAGE
        self.CustomColor = CustomColor
        self.HoldHandColor = HoldHandColor

        // Perform validation checks
        precondition(self.BRIGHTNESS_HIGH_THRESHOLD >= 0.0, "Invalid BRIGHTNESS_HIGH_THRESHOLD value")
        precondition(self.BRIGHTNESS_LOW_THRESHOLD >= 0.0, "Invalid BRIGHTNESS_LOW_THRESHOLD value")
        precondition(self.PREDICTION_LOW_PERCENTAGE >= 0.0, "Invalid PREDICTION_LOW_PERCENTAGE value")
        precondition(self.PREDICTION_HIGH_PERCENTAGE >= 0.0, "Invalid PREDICTION_HIGH_PERCENTAGE value")
        precondition(!self.CustomColor.isEmpty, "Invalid CustomColor value")
        precondition(!self.HoldHandColor.isEmpty, "Invalid HoldHandColor value")
    }

    func checkConditions(
        brightness: Double
    ) -> Bool {
        let isBrightnessValid = brightness >= Double(BRIGHTNESS_LOW_THRESHOLD) && brightness <= Double(BRIGHTNESS_HIGH_THRESHOLD)
        
        return  isBrightnessValid
    }

    func isPredictionValid(confidence: Float) -> Bool {
        let isValid = (confidence * 100) >= PREDICTION_LOW_PERCENTAGE && (confidence * 100) <= PREDICTION_HIGH_PERCENTAGE
        return isValid
    }

    func chekMotionValid(motion: Double) -> Bool {
        let MOTION_LOW_THRESHOLD = 0.0
        let MOTION_HIGH_THRESHOLD = 5.0

        return motion >= MOTION_LOW_THRESHOLD && motion <= MOTION_HIGH_THRESHOLD || motion == 0.0
    }
}


