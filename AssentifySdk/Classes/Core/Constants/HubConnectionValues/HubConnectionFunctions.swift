
import Foundation



class HubConnectionFunctions {
    static func etHubConnectionFunction(blockType: BlockType) -> String {
        switch blockType {
        case BlockType.READ_PASSPORT:
            return "api/IdentificationDocument/ReadPassport"
        case  BlockType.ID_CARD:
            return "api/IdentificationDocument/ReadId"
        case  BlockType.OTHER:
            return "api/IdentificationDocument/Other"
        case BlockType.FACE_MATCH:
            return "api/IdentificationDocument/FaceMatchWithImage"
        case BlockType.SIGNATURE:
            return "SIGNATURE"
        }
    }
}

