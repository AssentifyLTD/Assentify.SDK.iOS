
import SwiftUI
import SwiftUI

public struct HowToCaptureFaceScreen: View {
    
    
    let steps = LocalStepsObject.shared.get();
    
    func onBack ()  {
        flowController.backClick();
    }
    func onNext ()  {
        flowController.makeCurrentStepDone(extractedInformation: [:]);
        flowController.naveToNextStep();
    }
    
    private let flowController: FlowController
    
    
    
    public init(flowController: FlowController) {
        
        self.flowController = flowController
        
    }
    
    public var body: some View {
        BaseBackgroundContainer {
            VStack(spacing: 0) {
                ProgressStepperView(steps: steps!, bundle: .main)
                            .padding(.top, 20)
                // Header
                Text("HowToCaptureFaceScreen")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(Color(BaseTheme.baseTextColor))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 25)
                    .padding(.leading, 25)
                    .padding(.trailing, 20)
                
                
                
                    .frame(maxHeight: .infinity)
                
                BaseClickButton(title: "Next") {
                    onNext()
                }
                .padding(.vertical, 25)
                .padding(.horizontal, 25)
            } .topBarBackLogo {
                onBack()
            }
        } .modifier(InterceptSystemBack(action: onBack))
        
        
    }
}

