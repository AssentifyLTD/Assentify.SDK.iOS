import UIKit
import SwiftUI

public final class FlowController {
    
    private weak var navigationController: UINavigationController?
    private var flowDelegate:FlowDelegate?
    
    public init(navigationController: UINavigationController,flowDelegate:FlowDelegate) {
        self.navigationController = navigationController
        self.flowDelegate = flowDelegate
    }
    
    public func push<V: View>(_ screen: V, animated: Bool = true) {
        guard let nav = navigationController else { return }
        let vc = UIHostingController(rootView: screen)
        nav.pushViewController(vc, animated: animated)
    }
    
    public func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    public func dismiss(animated: Bool = true) {
        navigationController?.dismiss(animated: animated)
    }
    
    public func setRoot( animated: Bool = false) {
        let vc = UIHostingController(rootView:     BlockLoaderScreen(flowController: self))
        navigationController?.setViewControllers([vc], animated: animated)
    }
    
    public func endFlow(animated: Bool = false,submitRequestModel: [SubmitRequestModel]) {
        self.flowDelegate?.onFlowCompleted(submitRequestModel:submitRequestModel)
        self.dismiss(animated: animated)
    }
    
    public func naveToNextStep() {
        let currentStep = getCurrentStep()
        
        guard let currentStep else {
            push(SubmitStepScreen(flowController: self))
            return
        }
        
        switch currentStep.stepDefinition?.stepDefinition {
            
        case StepsNames.termsConditions:
            push(TermsAndConditionsScreen(flowController: self))
            
        case StepsNames.identificationDocumentCapture:
            push(IDStepScreen(flowController: self))
            
        case StepsNames.faceImageAcquisition:
            push(HowToCaptureFaceScreen(flowController: self))
            
        case StepsNames.assistedDataEntry:
            push(AssistedDataEntryScreen(flowController: self))
            
        case StepsNames.contextAwareSigning:
            push(MultipleFilesContextAwareScreen(flowController: self))
            
        default:
            push(SubmitStepScreen(flowController: self))
        }
    }
    
    public func getCurrentStep() -> LocalStepModel? {
        let steps = LocalStepsObject.shared.get()
        return steps!.first { $0.isDone == false }
    }
    
    public func makeCurrentStepDone(extractedInformation: [String: String]) {
        
        var steps = LocalStepsObject.shared.get()
        
        guard let currentIndex = steps!.firstIndex(where: { $0.isDone == false }) else { return }
        
        var currentStep = steps![currentIndex]
        
        let nextStep: LocalStepModel? = {
            let nextIndex = currentIndex + 1
            return nextIndex < steps!.count ? steps![nextIndex] : nil
        }()
        
        /// TODOSDK  Track Next
        // trackNext(currentStep: currentStep, nextStep: nextStep)
        
        var submitRequestModel = currentStep.submitRequestModel
        submitRequestModel?.extractedInformation = extractedInformation
        
        currentStep.isDone = true
        currentStep.submitRequestModel = submitRequestModel
        
        steps![currentIndex] = currentStep
        LocalStepsObject.shared.set(steps!)
    }
    
    public func backClick() {
        setRoot(animated: true)
    }
    
    
    public  func getFaceMatchInputImageKey() -> String {
        
        let key = ConstantsValues.providedFaceImageKey
        let currentStep = getCurrentStep()
        let steps = LocalStepsObject.shared.get()
        
        // Find FaceImageAcquisition step
        guard let faceStep = steps!.first(where: {
            $0.stepDefinition?.stepDefinition == StepsNames.faceImageAcquisition
        }),
              let stepDefinition = faceStep.stepDefinition,
              !stepDefinition.inputProperties.isEmpty,
              let currentStepId = currentStep?.stepDefinition?.stepId
        else {
            return key
        }
        
        let firstInput = stepDefinition.inputProperties.first!
        
        if firstInput.sourceStepId == currentStepId {
            return firstInput.sourceKey
        } else {
            return "NON"
        }
    }
    
    public  func  setImage(url: String) {
        IDImageObject.shared.clear();
        IDImageObject.shared.set(url)
    }
    
    public  func  getPreviousIDImage() -> String {
        return IDImageObject.shared.get() ?? ""
    }
    
    func faceIDChange() {
        var steps = LocalStepsObject.shared.get()
        
        if let index = steps!.firstIndex(where: {
            $0.stepDefinition?.stepDefinition == StepsNames.identificationDocumentCapture
        }) {
            steps![index].isDone = false
        }
        
        LocalStepsObject.shared.set(steps!)
    }

    
}
