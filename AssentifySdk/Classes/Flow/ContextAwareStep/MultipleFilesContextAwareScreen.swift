
import SwiftUI
import Foundation

public enum ContextAwareStepEventType: String {
    case onSend
    case onTokensComplete
    case onSignature
    case onError
}

// MARK: - Multiple Files Context Aware Screen
public struct MultipleFilesContextAwareScreen: View, ContextAwareDelegate {

    // MARK: Delegate callbacks
    public func onHasTokens(
        templateId: Int,
        documentTokens: [TokensMappings],
        contextAwareSigningModel: ContextAwareSigningModel
    ) {
        DispatchQueue.main.async {
            self.eventType = .onTokensComplete
            self.contextAwareSigningObject = contextAwareSigningModel
        
            self.selectedTemplates.append(
                SelectedTemplatesTokens(
                    templateId: templateId,
                    templateName: "Agreement",
                    documentTokens: documentTokens
                )
            )
            
            let raw = contextAwareSigningModel.data.confirmationMessage ?? ""
                  Task.detached(priority: .userInitiated) {
                      let cleaned = self.cleanedConfirmation(raw) // html -> plain
                          .replacingOccurrences(of: "\n", with: " ")
                          .replacingOccurrences(of: "  ", with: " ")
                          .trimmingCharacters(in: .whitespacesAndNewlines)

                      await MainActor.run {
                          self.confirmationCleaned = cleaned
                      }
             }
            

            if self.contextAwareSigningObject?.data.selectedTemplates.count == self.selectedTemplates.count {
                self.eventType = .onTokensComplete
            }
        }
    }

    public func onCreateUserDocumentInstance(userDocumentResponseModel: CreateUserDocumentResponseModel) {
        DispatchQueue.main.async {
            guard let tid = self.currentTemplateId else { return }
            self.documentWithTokensObject.append(
                DocumentWithTokensModel(
                    templateId: tid,
                    createUserDocumentResponseModel: userDocumentResponseModel
                )
            )
            self.eventType = .onTokensComplete
        }
    }

    public func onSignature(signatureResponseModel: SignatureResponseModel) {
        DispatchQueue.main.async {
            guard let firstApproved = self.approvedDocuments.first else { return }

            self.documentWithTokensAndSigned.append(
                DocumentWithTokensAndSinged(
                    templateId: firstApproved.templateId,
                    signatureResponseModel: signatureResponseModel
                )
            )
            if !self.approvedDocuments.isEmpty { self.approvedDocuments.removeFirst() }
            if self.contextAwareSigningObject?.data.selectedTemplates.count == self.documentWithTokensAndSigned.count {
                self.eventType = .onSignature
            } else {
                self.signNextApprovedIfPossible()
            }
            
            /** Track Progress **/
            let currentStep = flowController.getCurrentStep()
            var extractedInformation: [String: String] = [:]

            let outputProperties = flowController.getCurrentStep()?.stepDefinition?.outputProperties ?? []
            for outputProperty in outputProperties {
                if outputProperty.key.contains("OnBoardMe_ContextAwareSigning_DocumentURL") {
                    extractedInformation[outputProperty.key] = documentWithTokensAndSigned.first?.signatureResponseModel.signedDocumentUri ?? ""
                }
            }

            flowController.trackProgress(
                currentStep: currentStep!,
                inputData:extractedInformation,
                response: "Completed",
                status: "Completed"
            )
            /***/

        }
    }

    public func onError(message: String) {
        DispatchQueue.main.async {
            self.eventType = .onError
            self.errorMessage = message
        }
    }

    // MARK: Inputs
    private let flowController: FlowController
    private let steps = LocalStepsObject.shared.get()

    @State private var didStart: Bool = false
    @State private var eventType: ContextAwareStepEventType = .onSend
    @State private var contextAwareSigningObject: ContextAwareSigningModel? = nil
    @State private var confirmationCleaned: String = ""
    @State private var currentTemplateId: Int? = nil

    @State private var selectedTemplates: [SelectedTemplatesTokens] = []
    @State private var documentWithTokensObject: [DocumentWithTokensModel] = []
    @State private var documentWithTokensAndSigned: [DocumentWithTokensAndSinged] = []

    @State private var approvedDocuments: [DocumentWithTokensModel] = []
    @State private var signatureB64: String = ""
    @State private var signatureToReuse: String? = nil

    @State private var checked: Bool = false
    @State private var selectedTemplate: SelectedTemplatesTokens? = nil
    @State private var showTemplates: Bool = false

    @State private var errorMessage: String = "Something went wrong"

    // Keep a reference to signing engine if your SDK returns one
    @State private var contextAwareSigning: ContextAwareSigning? = nil

    private let timeStarted :String = getCurrentDateTimeForTracking();
    
    public init(flowController: FlowController) {
        self.flowController = flowController
    }

    // MARK: Start (like AssistedDataEntryScreen)
    private func startIfNeeded() {
        guard !didStart else { return }
        didStart = true

        eventType = .onSend
        selectedTemplates.removeAll()
        documentWithTokensObject.removeAll()
        documentWithTokensAndSigned.removeAll()
        approvedDocuments.removeAll()
        signatureB64 = ""
        signatureToReuse = nil
        checked = false
        selectedTemplate = nil
        showTemplates = false

        let stepId = flowController.getCurrentStep()?.stepDefinition?.stepId

        contextAwareSigning = AssentifySdkObject.shared.get()?.startContextAwareSigning(
            contextAwareDelegate: self,
            stepId: stepId
        )
    }

    // MARK: Actions
    private func onBack() {
        flowController.backClick()
    }

    private func onNext() {
        var extractedInformation: [String: String] = [:]

        let outputProperties = flowController.getCurrentStep()?.stepDefinition?.outputProperties ?? []
        for outputProperty in outputProperties {
            if outputProperty.key.contains("OnBoardMe_ContextAwareSigning_DocumentURL") {
                extractedInformation[outputProperty.key] = documentWithTokensAndSigned.first?.signatureResponseModel.signedDocumentUri ?? ""
            }
        }

        flowController.makeCurrentStepDone(extractedInformation: extractedInformation,timeStarted: self.timeStarted)
        flowController.naveToNextStep()
    }

    private func onCreateUserDocumentResponseModel(_ template: SelectedTemplatesTokens) {
        eventType = .onSend

        var tokenValues: [String: String] = [:]
        for token in template.documentTokens {
            tokenValues[String(token.tokenId)] = getValueByKey(token.sourceKey)
        }

        currentTemplateId = template.templateId
        contextAwareSigning?.createUserDocumentInstance(templateId: template.templateId, data: tokenValues)
    }

    private func onSignTapped() {
        guard !signatureB64.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        signatureToReuse = signatureB64
        guard let first = approvedDocuments.first else { return }
        eventType = .onSend
        contextAwareSigning?.signature(
            documentId: first.createUserDocumentResponseModel.documentId,
            documentInstanceId: first.createUserDocumentResponseModel.templateInstanceId,
            signature: signatureB64
        )
    }

    private func signNextApprovedIfPossible() {
        guard let sig = signatureToReuse, !sig.isEmpty else { return }
        guard let first = approvedDocuments.first else { return }

   
        contextAwareSigning?.signature(
            documentId: first.createUserDocumentResponseModel.documentId,
            documentInstanceId: first.createUserDocumentResponseModel.templateInstanceId,
            signature: sig
        )
    }

   

    private func getValueByKey(_ key: String) -> String {
        let doneList = flowController.getAllDoneSteps()
        for step in doneList {
            let list = step.submitRequestModel?.extractedInformation ?? [:]
            for info in list where info.key == key {
                return info.value
            }
        }
        return ""
    }

    private func removeHtml(_ value: String) -> String {
        guard let data = value.data(using: .utf8) else { return value }
        if let att = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {
            return att.string
        }
        return value
    }

    // MARK: UI helpers
    private func isTemplateApproved(_ templateId: Int) -> Bool {
        approvedDocuments.contains(where: { $0.templateId == templateId })
    }

    private func docForTemplate(_ templateId: Int) -> DocumentWithTokensModel? {
        documentWithTokensObject.first(where: { $0.templateId == templateId })
    }

    private func signedForTemplate(_ templateId: Int) -> DocumentWithTokensAndSinged? {
        documentWithTokensAndSigned.first(where: { $0.templateId == templateId })
    }

    // MARK: Body
    public var body: some View {
        BaseBackgroundContainer {
            VStack(spacing: 0) {

                VStack(spacing: 10) {
                    ProgressStepperView(steps: steps ?? [], bundle: .main)
                       
                }
                .padding(.top, 20)

                // Content
                ScrollView {
                    VStack(spacing: 16) {
                      

                        // Loading / Sending
                        if eventType == .onSend {
                            ZStack {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(Color(BaseTheme.baseTextColor))
                                    .scaleEffect(1.2)
                            }
                            .frame(minHeight: UIScreen.main.bounds.height * 0.6)
                            .frame(maxWidth: .infinity)
                        }

                        // Error
                        if eventType == .onError {
                            VStack(spacing: 12) {
                                Spacer(minLength: 40)
                                Text(errorMessage)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(BaseTheme.baseRedColor))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                Spacer(minLength: 40)
                            }
                        }

                        // Tokens complete OR signature step
                        if eventType == .onTokensComplete || eventType == .onSignature {

                            // ====== Main selection screen (when not inside a document viewer) ======
                            let shouldShowListScreen =
                                (selectedTemplate == nil)
                                || (selectedTemplate != nil && docForTemplate(selectedTemplate!.templateId) == nil)

                            if shouldShowListScreen {
                                // Header texts
                                if let obj = contextAwareSigningObject {
                                    Text(obj.data.header ?? "")
                                        .font(.system(size: 23, weight: .bold))
                                        .foregroundColor(Color(BaseTheme.baseTextColor))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 25)

                                    if let sub = obj.data.subHeader, !sub.isEmpty {
                                        Text(sub)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color(BaseTheme.baseTextColor))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 25)
                                    }

                                    if let conf = obj.data.confirmationMessage, !conf.isEmpty {
                                            Text(self.confirmationCleaned)
                                                .font(.system(size: 12, weight: .light))
                                                .foregroundColor(Color(BaseTheme.baseTextColor))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 25)
                                        
                                    }
                                }

                                Spacer(minLength: 50)
                                HStack(spacing: 0) {
                                    Toggle(isOn: Binding(
                                        get: { checked },
                                        set: { newVal in
                                            if approvedDocuments.count != selectedTemplates.count {
                                                checked = newVal
                                            }
                                        }
                                    )) {
                                        Text("I agree to the terms and conditions")
                                            .font(.system(size: 12, weight: .light))
                                            .foregroundColor(Color(BaseTheme.baseTextColor))
                                    }
                                    .toggleStyle(CheckboxToggleStyle(accent: Color(BaseTheme.baseAccentColor)))

                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)

                                Text(approvedDocuments.count != selectedTemplates.count
                                     ? "Please review and approve the below files"
                                     : "Thank you for approving")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(BaseTheme.baseTextColor))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 25)

                                // List of templates OR dropdown when all approved
                                if approvedDocuments.count != selectedTemplates.count {
                                    VStack(spacing: 10) {
                                        ForEach(selectedTemplates, id: \.templateId) { doc in
                                            DocumentRowView(
                                                title: doc.templateName,
                                                isApproved: isTemplateApproved(doc.templateId),
                                                isActive: checked,
                                                onTap: {
                                                    guard checked else { return }
                                                    selectedTemplate = doc
                                                    if docForTemplate(doc.templateId) == nil {
                                                        onCreateUserDocumentResponseModel(doc)
                                                    }
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                } else {
                                    Button {
                                        showTemplates.toggle()
                                    } label: {
                                        HStack {
                                            Text("Files Reviewed and Approved")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color(BaseTheme.baseTextColor))
                                            Spacer()
                                            Image(systemName: showTemplates ? "chevron.up" : "chevron.down")
                                                .foregroundColor(Color(BaseTheme.baseTextColor))
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color(BaseTheme.fieldColor))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                    }
                                    .padding(.horizontal, 25)

                                    if showTemplates {
                                        VStack(spacing: 10) {
                                            ForEach(selectedTemplates, id: \.templateId) { doc in
                                                DocumentRowView(
                                                    title: doc.templateName,
                                                    isApproved: isTemplateApproved(doc.templateId),
                                                    isActive: checked,
                                                    onTap: {
                                                        guard checked else { return }
                                                        selectedTemplate = doc
                                                        if docForTemplate(doc.templateId) == nil {
                                                            onCreateUserDocumentResponseModel(doc)
                                                        }
                                                    }
                                                )
                                            }
                                        }
                                        .padding(.horizontal, 25)
                                        .padding(.top, 8)
                                    }
                                }
                            }

                            // ====== Signed document viewer (eventType == onSignature) ======
                            if let sel = selectedTemplate,
                               let signed = signedForTemplate(sel.templateId),
                               eventType == .onSignature {

                                DocumentPageFromUrlView(
                                    url: signed.signatureResponseModel.signedDocumentUri,
                                    onCancel: { selectedTemplate = nil }
                                )
                                .padding(.top, 8)
                            }

                            // ====== Unsigned doc viewer (base64) ======
                            if let sel = selectedTemplate,
                               let doc = docForTemplate(sel.templateId),
                               eventType != .onSignature {

                                DocumentPageView(
                                    userDocumentResponseModel: doc.createUserDocumentResponseModel,
                                    isApproved: isTemplateApproved(sel.templateId),
                                    onAccept: {
                                        if !isTemplateApproved(sel.templateId) {
                                            approvedDocuments.append(
                                                DocumentWithTokensModel(
                                                    templateId: sel.templateId,
                                                    createUserDocumentResponseModel: doc.createUserDocumentResponseModel
                                                )
                                            )
                                        }
                                        selectedTemplate = nil
                                    },
                                    onCancel: { selectedTemplate = nil }
                                )
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 15)
                                .padding(.top, 8)
                            }

                            // ====== Signature pad when all approved (before signing) ======
                            if selectedTemplate == nil,
                               approvedDocuments.count == selectedTemplates.count,
                               eventType != .onSignature {

                                SignaturePadContainer(
                                    signatureBase64: $signatureB64
                                )
                                .padding(.top, 8)
                            }
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.top, 20)
                }

                if selectedTemplate == nil && eventType == .onTokensComplete {
                    BaseClickButton(
                        title: "Accept Terms & Sign",
                        verticalPadding: 18,
                        enabled: !signatureB64.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ) {
                        onSignTapped()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }

                if selectedTemplate == nil && eventType == .onSignature {
                    BaseClickButton(title: "Next", verticalPadding: 18, enabled: true) {
                        onNext()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .topBarBackLogo { onBack() }
        }
        .modifier(InterceptSystemBack(action: onBack))
        .task { startIfNeeded() }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func cleanedConfirmation(_ raw: String) -> String {
        removeHtml(raw)
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}



// MARK: - Document Row (SwiftUI version of DocumentRow)
fileprivate struct DocumentRowView: View {
    let title: String
    let isApproved: Bool
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {

                if isActive {
                    Image(systemName: isApproved ? "checkmark.circle" : "doc")
                        .font(.system(size: isApproved ? 22 : 18, weight: .semibold))
                        .foregroundColor(isApproved
                            ? Color(BaseTheme.baseGreenColor)
                            : Color(BaseTheme.baseAccentColor))
                        .frame(width: 26)
                } else {
                    Color.clear.frame(width: 26)
                }

                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(BaseTheme.baseTextColor).opacity(isActive ? 1.0 : 0.3))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "eye")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color(BaseTheme.baseAccentColor).opacity(isActive ? 1.0 : 0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(BaseTheme.fieldColor).opacity(isActive ? 1.0 : 0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Document Page (Base64 PDF)  (SwiftUI version of DocumentPage)
fileprivate struct DocumentPageView: View {
    let userDocumentResponseModel: CreateUserDocumentResponseModel
    let isApproved: Bool
    let onAccept: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 15) {

            PdfViewerFromBase64(base64Data: userDocumentResponseModel.templateInstance)
                .frame(maxWidth:  .infinity)
                .frame(height: !isApproved ?  UIScreen.main.bounds.height - 380 : UIScreen.main.bounds.height - 360)

            if !isApproved {
                BaseClickButton(title: "Approve", verticalPadding: 18, enabled: true) {
                    onAccept()
                }
            }

            OutlineButton(
                title: "Cancel",
                cornerRadius: 28,
                borderColor: Color(BaseTheme.baseAccentColor),
                textColor: Color(BaseTheme.baseAccentColor),
                height: 55,
                action: onCancel
            )
        }
    }
}

fileprivate struct ShareFile: Identifiable {
    let id = UUID()
    let url: URL
}

fileprivate struct DocumentPageFromUrlView: View {
    let url: String
    let onCancel: () -> Void

    @State private var shareFile: ShareFile? = nil
    @State private var showFullScreen: Bool = false

    var body: some View {
        VStack(spacing: 15) {
            BasePDFCardViewFomUrl(
                urlString: url,
                tintColor: BaseTheme.baseTextColor,
                onDownloadTap: { downloadAndShare(url) },
                onFullScreenTap: { showFullScreen = true }
            )
            .frame(height: UIScreen.main.bounds.height - 350)
            .padding(.horizontal, 15)

            OutlineButton(
                title: "Cancel",
                cornerRadius: 28,
                borderColor: Color(BaseTheme.baseAccentColor),
                textColor: Color(BaseTheme.baseAccentColor),
                height: 55,
                action: onCancel
            )
            .padding(.horizontal, 15)
        }
        .sheet(item: $shareFile) { file in
            ShareSheet(items: [file.url])
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenPDFView(urlString: url)
        }
    }

    private func downloadAndShare(_ urlString: String) {
        guard let u = URL(string: urlString) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: u)
                let fileURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("SignedDocument_\(UUID().uuidString).pdf")

                try data.write(to: fileURL, options: [.atomic])

                // ✅ Present ONLY after file exists
                shareFile = ShareFile(url: fileURL)

            } catch {
                // optional: show toast / error state
            }
        }
    }
}


fileprivate struct SignaturePadContainer: View {
    @Binding var signatureBase64: String

    var body: some View {
        SignaturePad(title: "Signature") { b64 in
            signatureBase64 = b64
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .padding(.horizontal, 25)
    }
}

// MARK: - Tiny helpers
fileprivate struct CheckboxToggleStyle: ToggleStyle {
    let accent: Color
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(accent)
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}





public struct SelectedTemplatesTokens: Codable {
    public let templateId: Int
    public let templateName: String
    public let documentTokens: [TokensMappings]

    public init(
        templateId: Int,
        templateName: String,
        documentTokens: [TokensMappings]
    ) {
        self.templateId = templateId
        self.templateName = templateName
        self.documentTokens = documentTokens
    }
}

public struct DocumentWithTokensModel: Codable {
    public let templateId: Int
    public let createUserDocumentResponseModel: CreateUserDocumentResponseModel

    public init(
        templateId: Int,
        createUserDocumentResponseModel: CreateUserDocumentResponseModel
    ) {
        self.templateId = templateId
        self.createUserDocumentResponseModel = createUserDocumentResponseModel
    }
}

public struct DocumentWithTokensAndSinged: Codable {
    public let templateId: Int
    public let signatureResponseModel: SignatureResponseModel

    public init(
        templateId: Int,
        signatureResponseModel: SignatureResponseModel
    ) {
        self.templateId = templateId
        self.signatureResponseModel = signatureResponseModel
    }
}

private struct OutlineButton: View {

    let title: String
    let cornerRadius: CGFloat
    let borderColor: Color
    let textColor: Color
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .contentShape(Rectangle())
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
