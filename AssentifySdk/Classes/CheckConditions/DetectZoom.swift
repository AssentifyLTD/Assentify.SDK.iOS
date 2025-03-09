
import Foundation

let ZoomLimit = 25;
let FaceZoomLimit = 10;

func calculatePercentageChangeWidth(rect: CGRect) -> ZoomType {
        let aspectRatioDifference = rect.width

        if (500...800).contains(aspectRatioDifference) {
            return .SENDING
        }
        if aspectRatioDifference < 500 {
            return .ZOOM_IN
        }
        if aspectRatioDifference > 800 {
            return .ZOOM_OUT
        }
        return .NO_DETECT
    }

