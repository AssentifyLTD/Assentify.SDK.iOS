import SwiftUI
import UIKit

public struct SecurePhoneWithOtpField: View {

    public let title: String
    public let page: Int
    public let flowController: FlowController

    @Binding public var field: DataEntryPageElement

    public let onValueChange: (String) -> Void          // full E164
    public let onValid: () -> Void

    // focus support
    @Binding public var focusedFieldId: String?
    public let fieldId: String

    // Lebanon constants
    private let countryFlag = "🇱🇧"
    private let countryIso2 = "LB"
    private let countryDial = "+961"

    @State private var localNumber: String = ""         // user types here (no dial)
    @State private var otp: String = ""

    @State private var isOtpStep: Bool = false
    @State private var isVerified: Bool = false
    @State private var verifying: Bool = false

    @State private var errToShow: String = ""

    public init(
        title: String,
        page: Int,
        field: Binding<DataEntryPageElement>,
        flowController: FlowController,
        focusedFieldId: Binding<String?>,
        fieldId: String,
        onValueChange: @escaping (String) -> Void,
        onValid: @escaping () -> Void
    ) {
        self.title = title
        self.page = page
        self._field = field
        self.flowController = flowController
        self._focusedFieldId = focusedFieldId
        self.fieldId = fieldId
        self.onValueChange = onValueChange
        self.onValid = onValid
        if (self.field.isHidden == true){
            syncInitialPhone()
        }
    }

    public var body: some View {
        if (self.field.isHidden == false){

            VStack(alignment: .leading, spacing: 6) {
                Text(headerTitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(BaseTheme.baseTextColor))
                
                if !isOtpStep {
                    phoneRow()
                } else {
                    otpField()
                    otpFooter()
                }
                
                if verifying {
                    Text("Otp verifying ...")
                        .font(.system(size: 12))
                        .foregroundColor(Color(BaseTheme.baseAccentColor))
                        .padding(.top, 4)
                }
                
                if !errToShow.isEmpty {
                    Text(errToShow)
                        .font(.system(size: 12))
                        .foregroundColor(Color(BaseTheme.baseRedColor))
                        .padding(.top, 4)
                }
            
        }
            .onAppear {
                syncInitialPhone()
                recomputePhoneError()
            }
            .onChange(of: localNumber) { _ in
                // 1) update full token
                let full = buildLebanonE164(localNumber, countryDial: countryDial)
                onValueChange(full)
                // 2) (optional) store in model like your other fields
                if let key = field.inputKey {
                    AssistedFormHelper.changeValue(key, full, page)
                }
                recomputePhoneError()
            }
    }
    }

    // MARK: - Derived

    private var headerTitle: String {
        (!isOtpStep || isVerified) ? title : "Enter OTP"
    }

    private var otpSize: Int {
        Int(field.otpSize ?? 6)
    }

    private var otpType: Int {
        Int(field.otpType ?? 1) // 1 numeric, 2 alnum, 3 letters
    }

    private var expiryMinutes: Double {
        field.otpExpiryTime ?? 1.0
    }

    private var isReadOnly: Bool {
        (field.readOnly ?? false)
    }

    private var e164Phone: String {
        buildLebanonE164(localNumber, countryDial: countryDial)
    }

    // MARK: - UI

    @ViewBuilder
    private func phoneRow() -> some View {
        HStack(spacing: 10) {

            // Left fixed pill: 🇱🇧 +961
            Text("\(countryFlag) \(countryDial)")
                .font(.system(size: 16))
                .foregroundColor(Color(BaseTheme.baseTextColor))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .frame(width: 130, height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(BaseTheme.fieldColor))
                )

            // Right input: local digits
            UIKitPhoneTextField(
                text: Binding(
                    get: { localNumber },
                    set: { raw in
                        // digits only, allow spaces/dashes then strip
                        let digits = raw.filter { $0.isNumber }
                        localNumber = String(digits.prefix(8)) // LB usually 7–8
                    }
                ),
                isFirstResponder: Binding(
                    get: { focusedFieldId == fieldId },
                    set: { newValue in
                        if newValue { focusedFieldId = fieldId }
                        else if focusedFieldId == fieldId { focusedFieldId = nil }
                    }
                ),
                isEnabled: !isReadOnly
            )
            .frame(height: 55)
            .overlay(alignment: .trailing) {

                if phoneLooksValidLB(localNumber) {
                    Button {
                        sendOtp()
                    } label: {
                        Text("Send OTP")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(BaseTheme.baseTextColor))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(BaseTheme.baseAccentColor))
                            )
                    }
                    .padding(.trailing, 6)
                    .disabled(isReadOnly)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(BaseTheme.fieldColor))
            )
            .contentShape(Rectangle())
            .onTapGesture { focusedFieldId = fieldId }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func otpField() -> some View {
        HStack(spacing: 10) {
            UIKitOtpTextField(
                text: Binding(
                    get: { isVerified ? e164Phone : otp },
                    set: { raw in
                        guard !isVerified else { return }
                        let filtered = filterByOtpType(raw, otpType: otpType)
                        otp = String(filtered.prefix(otpSize))

                        if otp.count == otpSize, otpMatchesType(otp, otpType: otpType) {
                            verifyOtp()
                        }
                    }
                ),
                isFirstResponder: Binding(
                    get: { focusedFieldId == fieldId },
                    set: { newValue in
                        if newValue { focusedFieldId = fieldId }
                        else if focusedFieldId == fieldId { focusedFieldId = nil }
                    }
                ),
                isEnabled: !isReadOnly && !isVerified,
                keyboardType: otpKeyboardType(otpType)
            )
            .frame(height: 55)
        }
        .padding(.horizontal, 14)
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(BaseTheme.fieldColor))
        )
        .contentShape(Rectangle())
        .onTapGesture { focusedFieldId = fieldId }
    }

    @ViewBuilder
    private func otpFooter() -> some View {
        HStack {
            if isVerified {
                Text("Verified successfully")
                    .font(.system(size: 12))
                    .foregroundColor(Color(BaseTheme.baseAccentColor))
            } else {
                if !verifying {
                    ResendOtpControl(expiryMinutes: expiryMinutes) {
                        resendOtp()
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 6)
    }

    // MARK: - Logic

    private func syncInitialPhone() {
        // if your stored value is full E164, extract local part for UI
        if let existing = field.value, !existing.isEmpty {
            let digits = existing.filter { $0.isNumber }
            // try to remove 961 prefix if present
            if digits.hasPrefix("961") {
                localNumber = String(digits.dropFirst(3))
            } else {
                localNumber = digits
            }
        }
    }

    private func recomputePhoneError() {
        if localNumber.isNotBlank, !phoneLooksValidLB(localNumber) {
            errToShow = "Please enter a valid Lebanese number"
        } else {
            errToShow = ""
        }
    }

    private func sendOtp() {
        guard phoneLooksValidLB(localNumber) else { return }
        guard !isReadOnly else { return }

        guard let config = ConfigModelObject.shared.get() else { return }

        let request = RequestOtpModel(
            token: e164Phone,
            inputType: field.inputType,
            otpSize: otpSize,
            otpType: otpType,
            otpExpiryTime: expiryMinutes
        )

        OtpHelper.requestOtp(config: config, requestOtpModel: request) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    isOtpStep = true
                    otp = ""
                    isVerified = false
                }
            case .failure(let err):
                print(err)
            }
        }
    }

    private func resendOtp() {
        sendOtp()
    }

    private func verifyOtp() {
        guard phoneLooksValidLB(localNumber) else { return }
        guard otp.count == otpSize else { return }
        guard let config = ConfigModelObject.shared.get() else { return }

        verifying = true

        let req = VerifyOtpRequestOtpModel(
            token: e164Phone,
            otp: otp,
            otpExpiryTime: expiryMinutes
        )

        OtpHelper.verifyOtp(config: config, verifyOtpRequestOtpModel: req) { result in
            switch result {
            case .success(let ok):
                DispatchQueue.main.async {
                    verifying = false
                    if ok {
                        isVerified = true
                        onValid()
                    } else {
                        isVerified = false
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    verifying = false
                    isVerified = false
                }
            }
        }
    }

    // MARK: - Helpers (same idea as Kotlin)

    private func otpMatchesType(_ value: String, otpType: Int) -> Bool {
        switch otpType {
        case 1: return value.allSatisfy { $0.isNumber }
        case 2: return value.allSatisfy { $0.isLetter || $0.isNumber }
        case 3: return value.allSatisfy { $0.isLetter }
        default: return true
        }
    }

    private func filterByOtpType(_ raw: String, otpType: Int) -> String {
        switch otpType {
        case 1: return raw.filter { $0.isNumber }
        case 2: return raw.filter { $0.isLetter || $0.isNumber }
        case 3: return raw.filter { $0.isLetter }
        default: return raw
        }
    }

    private func otpKeyboardType(_ otpType: Int) -> UIKeyboardType {
        switch otpType {
        case 1: return .numberPad
        case 2: return .asciiCapable
        case 3: return .default
        default: return .asciiCapable
        }
    }
}

// MARK: - Lebanon helpers (same as Kotlin)

fileprivate func phoneLooksValidLB(_ local: String) -> Bool {
    let digits = local.filter { $0.isNumber }
    let normalized = digits.hasPrefix("0") ? String(digits.dropFirst(1)) : digits
    return (7...8).contains(normalized.count)
}

fileprivate func buildLebanonE164(_ local: String, countryDial: String = "+961") -> String {
    let digits = local.filter { $0.isNumber }
    let normalized = digits.hasPrefix("0") ? String(digits.dropFirst(1)) : digits
    return countryDial + normalized
}

// MARK: - Small helpers

fileprivate extension String {
    var isNotBlank: Bool { !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

// MARK: - UIKit phone field (same padding class you used)

fileprivate struct UIKitPhoneTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    let isEnabled: Bool

    func makeUIView(context: Context) -> UITextField {
        let tf = PaddedTextFieldEmail()
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.textColor = UIColor(Color(BaseTheme.baseTextColor))
        tf.keyboardType = .numberPad
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.delegate = context.coordinator
        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged), for: .editingChanged)
        tf.font = .systemFont(ofSize: 16)
        tf.placeholder = ""
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.isEnabled = isEnabled
        if uiView.text != text { uiView.text = text }

        if isFirstResponder, !uiView.isFirstResponder { uiView.becomeFirstResponder() }
        else if !isFirstResponder, uiView.isFirstResponder { uiView.resignFirstResponder() }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFirstResponder: $isFirstResponder)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool

        init(text: Binding<String>, isFirstResponder: Binding<Bool>) {
            self._text = text
            self._isFirstResponder = isFirstResponder
        }

        @objc func editingChanged(_ sender: UITextField) {
            let v = sender.text ?? ""
            if text != v { text = v }
        }

        func textFieldDidBeginEditing(_ textField: UITextField) { if !isFirstResponder { isFirstResponder = true } }
        func textFieldDidEndEditing(_ textField: UITextField) { if isFirstResponder { isFirstResponder = false } }
    }
}

fileprivate struct UIKitOtpTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    let isEnabled: Bool
    let keyboardType: UIKeyboardType
    
    func makeUIView(context: Context) -> UITextField {
        let tf = PaddedTextFieldPhone()
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.textColor = UIColor(Color(BaseTheme.baseTextColor))
        tf.keyboardType = keyboardType
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.delegate = context.coordinator
        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged), for: .editingChanged)
        tf.font = .systemFont(ofSize: 16)
        tf.placeholder = "OTP"
        return tf
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.isEnabled = isEnabled
        uiView.keyboardType = keyboardType
        
        if uiView.text != text { uiView.text = text }
        
        if isFirstResponder, !uiView.isFirstResponder { uiView.becomeFirstResponder() }
        else if !isFirstResponder, uiView.isFirstResponder { uiView.resignFirstResponder() }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFirstResponder: $isFirstResponder)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool
        
        init(text: Binding<String>, isFirstResponder: Binding<Bool>) {
            self._text = text
            self._isFirstResponder = isFirstResponder
        }
        
        @objc func editingChanged(_ sender: UITextField) {
            let v = sender.text ?? ""
            if text != v { text = v }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) { if !isFirstResponder { isFirstResponder = true } }
        func textFieldDidEndEditing(_ textField: UITextField) { if isFirstResponder { isFirstResponder = false } }
    }
}

