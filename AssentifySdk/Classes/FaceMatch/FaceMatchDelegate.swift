

import Foundation

public protocol FaceMatchDelegate{
    func onError(dataModel: RemoteProcessingModel )

    func onSend()

    func onRetry(dataModel: RemoteProcessingModel )

    func onClipPreparationComplete(dataModel: RemoteProcessingModel )

    func onStatusUpdated(dataModel: RemoteProcessingModel )

    func onUpdated(dataModel: RemoteProcessingModel )

    func onLivenessUpdate(dataModel: RemoteProcessingModel )

    func onComplete(dataModel: RemoteProcessingModel )

    func onCardDetected(dataModel: RemoteProcessingModel )

    func onMrzExtracted(dataModel: RemoteProcessingModel )

    func onMrzDetected(dataModel: RemoteProcessingModel )

    func onNoMrzDetected(dataModel: RemoteProcessingModel )

    func onFaceDetected(dataModel: RemoteProcessingModel )

    func onNoFaceDetected(dataModel: RemoteProcessingModel )

    func onFaceExtracted(dataModel: RemoteProcessingModel )

    func onQualityCheckAvailable(dataModel: RemoteProcessingModel )

    func onDocumentCaptured(dataModel: RemoteProcessingModel )

    func onDocumentCropped(dataModel: RemoteProcessingModel )

    func onUploadFailed(dataModel: RemoteProcessingModel )

    func onEnvironmentalConditionsChange(
           brightness: Double,
           motion: MotionType
       )
    
    func onHasTemplates(templates: [TemplatesByCountry])

}
