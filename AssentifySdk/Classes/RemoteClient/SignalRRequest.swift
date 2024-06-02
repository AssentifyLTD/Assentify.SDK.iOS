//
//  SignalRRequest.swift
//  AssentifyDemoApp
//
//  Created by TariQ on 20/02/2024.
//

import Foundation
import Foundation

public struct SignalRRequest: Encodable {
    let connectionId: String?
    let tenantId: String?
    let blockId: String?
    let instanceId: String?
    let totalNumberOfClipsProcessed: Int
    let traceIdentifier: String?
    let isMobile: Bool
    let saveCapturedVideo: Bool
    let storeCapturedDocument: Bool
    let userAgentString: String?
    let mime: String?
    let image: String?
    let requireFaceExtraction: Bool
    let enableSlimProcessing: Bool
    let storeImageStream: Bool
    let processMrz: Bool
    let templateId: String?
    let ipAddress: String?
    let checkForFace: Bool
    let isLivenessEnabled: Bool
    let videoClipB64: String?
    let isVideo: Bool
    let clips: [String]
    let secondImage: String

    enum CodingKeys: String, CodingKey {
        case connectionId, tenantId, blockId, instanceId, totalNumberOfClipsProcessed, traceIdentifier, isMobile
        case saveCapturedVideo, storeCapturedDocument, userAgentString, mime, image, requireFaceExtraction
        case enableSlimProcessing, storeImageStream, processMrz, templateId, ipAddress, checkForFace, isLivenessEnabled
        case videoClipB64, isVideo, clips, secondImage
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(connectionId, forKey: .connectionId)
        try container.encodeIfPresent(tenantId, forKey: .tenantId)
        try container.encodeIfPresent(blockId, forKey: .blockId)
        try container.encodeIfPresent(instanceId, forKey: .instanceId)
        try container.encode(totalNumberOfClipsProcessed, forKey: .totalNumberOfClipsProcessed)
        try container.encodeIfPresent(traceIdentifier, forKey: .traceIdentifier)
        try container.encode(isMobile, forKey: .isMobile)
        try container.encode(saveCapturedVideo, forKey: .saveCapturedVideo)
        try container.encode(storeCapturedDocument, forKey: .storeCapturedDocument)
        try container.encodeIfPresent(userAgentString, forKey: .userAgentString)
        try container.encodeIfPresent(mime, forKey: .mime)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encode(requireFaceExtraction, forKey: .requireFaceExtraction)
        try container.encode(enableSlimProcessing, forKey: .enableSlimProcessing)
        try container.encode(storeImageStream, forKey: .storeImageStream)
        try container.encode(processMrz, forKey: .processMrz)
        try container.encodeIfPresent(templateId, forKey: .templateId)
        try container.encodeIfPresent(ipAddress, forKey: .ipAddress)
        try container.encode(checkForFace, forKey: .checkForFace)
        try container.encode(isLivenessEnabled, forKey: .isLivenessEnabled)
        try container.encodeIfPresent(videoClipB64, forKey: .videoClipB64)
        try container.encode(isVideo, forKey: .isVideo)
        try container.encode(clips, forKey: .clips)
        try container.encode(secondImage, forKey: .secondImage)
    }
}


func prepareRequest(tenantId: String,
                    blockId: String,
                    instanceId: String,
                    message: String,
                    templateId: String,
                    secondImage: String,
                    checkForFace: Bool,
                    processMrz: Bool,
                    performLivenessDetection: Bool,
                    saveCapturedVideo: Bool,
                    storeCapturedDocument: Bool,
                    storeImageStream: Bool,
                    clips: [String]) -> SignalRRequest {
    
    let signalRRequest: SignalRRequest
    if !secondImage.isEmpty {
        signalRRequest = SignalRRequest(connectionId: "",
                                                            tenantId: tenantId,
                                                            blockId: blockId,
                                                            instanceId: instanceId,
                                                            totalNumberOfClipsProcessed: 12,
                                                            traceIdentifier: "traceIdentifier",
                                                            isMobile: true,
                                                            saveCapturedVideo: saveCapturedVideo,
                                                            storeCapturedDocument: storeCapturedDocument,
                                                            userAgentString: "",
                                                            mime: "video/mp4",
                                                            image: "base64EncodedStringOrPlaceholder",
                                                            requireFaceExtraction: false,
                                                            enableSlimProcessing: true,
                                                            storeImageStream: storeImageStream,
                                                            processMrz: processMrz,
                                                            templateId: "",
                                                            ipAddress: "sampleIpAddress",
                                                            checkForFace: checkForFace,
                                                            isLivenessEnabled: performLivenessDetection,
                                                            videoClipB64: message,
                                                            isVideo: false,
                                                            clips: clips,
                                                            secondImage: secondImage)
    } else {
        signalRRequest = SignalRRequest(connectionId: "",
                                                            tenantId: tenantId,
                                                            blockId: blockId,
                                                            instanceId: instanceId,
                                                            totalNumberOfClipsProcessed: 12,
                                                            traceIdentifier: "traceIdentifier",
                                                            isMobile: true,
                                                            saveCapturedVideo: saveCapturedVideo,
                                                            storeCapturedDocument: storeCapturedDocument,
                                                            userAgentString: "",
                                                            mime: "video/mp4",
                                                            image: "base64EncodedStringOrPlaceholder",
                                                            requireFaceExtraction: false,
                                                            enableSlimProcessing: true,
                                                            storeImageStream: storeImageStream,
                                                            processMrz: processMrz,
                                                            templateId: templateId,
                                                            ipAddress: "sampleIpAddress",
                                                            checkForFace: checkForFace,
                                                            isLivenessEnabled: false,
                                                            videoClipB64: message,
                                                            isVideo: false,
                                                            clips: [],
                                                            secondImage: secondImage)
    }
    
    return signalRRequest
}


