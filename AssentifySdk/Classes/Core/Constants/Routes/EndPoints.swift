//


import Foundation


struct EndPoints {
    static let identificationDocumentCapture = BaseUrls.signalRHub + "identification-document-capture"
    static let faceMatch = BaseUrls.signalRHub + "extract-face"
}

struct EndPointsUrls {
    static func getEndPointsUrls(blockType: BlockType) -> String {
        switch blockType {
        case BlockType.READ_PASSPORT, BlockType.ID_CARD, BlockType.OTHER:
            return EndPoints.identificationDocumentCapture
        case BlockType.FACE_MATCH:
            return EndPoints.faceMatch
        case BlockType.SIGNATURE:
            return "SIGNATURE"
        }
    }
}

