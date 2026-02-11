import SwiftUI

public struct SubmitStepScreen: View {

    private let flowController: FlowController


    public init(flowController: FlowController) {
        self.flowController = flowController

    }
    public var body: some View {
           VStack(alignment: .leading, spacing: 16) {

               VStack {
                   Text("SubmitStepScreen")
                       .font(.title)
                       .fontWeight(.bold)

                   Spacer()
                   BaseClickButton(title: "Back") {
                       flowController.backClick();
                   }
                   .padding(.vertical, 25)
                   .padding(.horizontal, 25)
                   
                   BaseClickButton(title: "Next") {
                       flowController.endFlow(submitRequestModel: [] );
                   }
                   .padding(.vertical, 25)
                   .padding(.horizontal, 25)
               }


               Spacer()
           }
           .padding()
       }
}

