
import SwiftUI

public struct IDStepScreen: View {

    private let flowController: FlowController


    public init(flowController: FlowController) {
        self.flowController = flowController

    }
    public var body: some View {
           VStack(alignment: .leading, spacing: 16) {

               VStack {
                   Text("IDStepScreen")
                       .font(.title)
                       .fontWeight(.bold)

                   Spacer()
                   BaseClickButton(title: "Back") {
                       flowController.backClick();
                   }
                   .padding(.vertical, 25)
                   .padding(.horizontal, 25)
                   
                   BaseClickButton(title: "Next") {
                       flowController.makeCurrentStepDone(extractedInformation: [:]);
                       flowController.naveToNextStep();
                   }
                   .padding(.vertical, 25)
                   .padding(.horizontal, 25)
               }


               Spacer()
           }
           .padding()
       }
}
