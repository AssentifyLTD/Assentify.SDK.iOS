

import Foundation



public class EnvironmentalConditions {


    /**Detect**/
    var enableDetect: Bool
    var enableGuide: Bool

    var CustomColor: String
    var HoldHandColor: String



    public  init(
        enableDetect: Bool = true,
        enableGuide:Bool = true,
        CustomColor: String,
        HoldHandColor: String
    ) {
        self.enableDetect = enableDetect
        self.enableGuide = enableGuide
        self.CustomColor = CustomColor
        self.HoldHandColor = HoldHandColor

        // Perform validation checks
        precondition(!self.CustomColor.isEmpty, "Invalid CustomColor value")
        precondition(!self.HoldHandColor.isEmpty, "Invalid HoldHandColor value")
    }

    func checkConditions(brightness: Double) -> BrightnessEvents {
        if brightness < ConstantsValues.BRIGHTNESS_LOW_THRESHOLD {
            return BrightnessEvents.TooDark
        } else if brightness > ConstantsValues.BRIGHTNESS_HIGH_THRESHOLD {
            return BrightnessEvents.TooBright
        } else {
            return BrightnessEvents.Good
        }
    }


    func isPredictionValid(confidence: Float) -> Bool {
        let isValid = (confidence * 100) >= ConstantsValues.PREDICTION_LOW_PERCENTAGE && (confidence * 100) <= ConstantsValues.PREDICTION_HIGH_PERCENTAGE
        return isValid
    }

    func chekMotionValid(motion: Double) -> Bool {
        let MOTION_LOW_THRESHOLD = 0.0
        let MOTION_HIGH_THRESHOLD = 5.0

        return motion >= MOTION_LOW_THRESHOLD && motion <= MOTION_HIGH_THRESHOLD || motion == 0.0
    }
}


