

import Foundation

public protocol ScanIDCardDelegate{
    func onError(dataModel: RemoteProcessingModel )

    func onSend()

    func onRetry(dataModel: RemoteProcessingModel )

    func onClipPreparationComplete(dataModel: RemoteProcessingModel )

    func onStatusUpdated(dataModel: RemoteProcessingModel )

    func onUpdated(dataModel: RemoteProcessingModel )

    func onLivenessUpdate(dataModel: RemoteProcessingModel )

    func onComplete(dataModel: RemoteProcessingModel,order:Int )

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
    
    func onWrongTemplate(dataModel: RemoteProcessingModel )

    func onEnvironmentalConditionsChange(
           brightness: Double,
           motion: MotionType,
           zoom: ZoomType
       )
    
    func onHasTemplates(templates: [TemplatesByCountry])

}
