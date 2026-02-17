import SwiftUI

public struct TermsAndConditionsScreen: View {
    
    
    
    @Environment(\.dismiss) private var dismiss
    
    private let flowController: FlowController
    
    private let steps = LocalStepsObject.shared.get()
    private let apiKey = ApiKeyObject.shared.get()
    private let configModel = ConfigModelObject.shared.get()
    
    @State private var isLoading: Bool = true
    @State private var termsModel: TermsConditionsModel? = nil
    
    @State private var showFullScreenPDF = false
    @State private var showShare = false
    @State private var shareItems: [Any] = []
    @State private var sharePayload: SharePayload?
    
    public init(flowController: FlowController) {
        self.flowController = flowController
    }
    
    private func onBack() {
        flowController.backClick()
    }
    
    
    
    
    private func onNext(value:Bool) {
        if let step = flowController.getCurrentStep(),
           let stepDefinition = step.stepDefinition,
           let firstProperty = stepDefinition.outputProperties.first {
            let confirmationKey = firstProperty.key
            let extractedInformation: [String: String] = [
                confirmationKey: String(describing: value)
            ]
            flowController.makeCurrentStepDone(extractedInformation:extractedInformation)
            flowController.naveToNextStep()
        }
        
    }
    
    public var body: some View {
        BaseBackgroundContainer {
            VStack(spacing: 0) {
                
                ProgressStepperView(steps: steps ?? [], bundle: .main)
                    .padding(.top, 20)
                
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color(BaseTheme.baseTextColor))
                            .scaleEffect(1.2)
                        Spacer()
                    }
                }
                else {
                    Text(termsModel?.data.header ?? "Terms And Conditions")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(BaseTheme.baseTextColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 18)
                        .padding(.horizontal, 20)
                    if(termsModel?.data.subHeader != nil){
                        Text((termsModel?.data.subHeader)!)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color(BaseTheme.baseTextColor))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                            .padding(.horizontal, 20)
                    }
                    
                    
                    
                    // Divider line
                    Rectangle()
                        .fill(Color(BaseTheme.baseTextColor).opacity(0.2))
                        .frame(height: 1)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                    
                    // PDF Card
                    ZStack {
                        BasePDFCardViewFomUrl(
                            urlString: termsModel?.data.file,
                            tintColor: BaseTheme.baseTextColor,
                            onDownloadTap: { onDownloadPDF() },
                            onFullScreenTap: { showFullScreenPDF = true }
                        )
                        .padding(.top, 14)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    .frame(maxHeight: .infinity)
                    
                    // Bottom buttons
                    HStack(spacing: 16) {
                        
                        Button {
                            if (termsModel?.data.confirmationRequired == true) {
                                onBack()
                            } else {
                                onNext(value: false)
                            }
                        } label: {
                            Text("Decline")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(BaseTheme.baseAccentColor))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color(BaseTheme.baseAccentColor), lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        BaseClickButton(title: termsModel?.data.nextButtonTitle ?? "Next",verticalPadding:18,) {
                            onNext(value: true)
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            } 
            .topBarBackLogo {
                onBack()
            }
        } .modifier(InterceptSystemBack(action: onBack))
            .task { await loadTerms() }
            .sheet(isPresented: $showFullScreenPDF) {
                FullScreenPDFView(urlString: termsModel?.data.file)
            }
            .sheet(item: $sharePayload) { payload in
                ShareSheet(items: payload.items)
            }
    }
    
    private struct SharePayload: Identifiable {
        let id = UUID()
        let items: [Any]
    }
    
    // MARK: - Download
    
    private func onDownloadPDF() {
        guard let s = termsModel?.data.file, let url = URL(string: s) else { return }
        sharePayload = SharePayload(items: [url])
    }
    
    // MARK: - API
    
    @MainActor
    private func loadTerms() async {
        guard let apiKey, let configModel else {
            isLoading = false
            return
        }
        
        isLoading = true
        termsModel = nil
        
        let stepId = flowController.getCurrentStep()?.stepDefinition?.stepId
        
        getTermsConditionsStep(
            apiKey: apiKey,
            userAgent: "SDK",
            flowInstanceId: configModel.flowInstanceId,
            tenantIdentifier: configModel.tenantIdentifier, // keep your existing value
            blockIdentifier: configModel.blockIdentifier,
            instanceId: configModel.instanceId,
            flowIdentifier: configModel.flowIdentifier,
            instanceHash: configModel.instanceHash,
            ID: stepId!
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                if case .success(let model) = result {
                    self.termsModel = model
                }
            }
        }
    }
}
