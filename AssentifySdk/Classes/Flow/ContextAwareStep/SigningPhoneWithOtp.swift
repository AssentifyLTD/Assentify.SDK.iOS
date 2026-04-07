import SwiftUI
import UIKit

public struct SigningPhoneWithOtp: View {
    
    public let title: String
    public let flowController: FlowController
    public var contextAwareSigningModel: ContextAwareSigningModel
    
    public let onValueChange: (String) -> Void   // full E164 phone
    public let onValid: () -> Void
    
    // Lebanon constants
    private let countryFlag = "🇱🇧"
    private let countryDial = "+961"
    
    @State private var localNumber: String = ""
    @State private var otp: String = ""
    
    @State private var isOtpStep: Bool = false
    @State private var isVerified: Bool = false
    @State private var verifying: Bool = false
    @State private var sendingOtp: Bool = false
    
    @State private var requestError: String = ""
    @State private var errToShow: String = ""
    
    @State private var searchQuery: String = ""
    @State private var userStartedTyping: Bool = false
    @State private var showCountryDialog: Bool = false
    
    public init(
        title: String,
        contextAwareSigningModel: ContextAwareSigningModel,
        flowController: FlowController,
        onValueChange: @escaping (String) -> Void,
        onValid: @escaping () -> Void
    ) {
        self.title = title
        self.contextAwareSigningModel = contextAwareSigningModel
        self.flowController = flowController
        self.onValueChange = onValueChange
        self.onValid = onValid
    }
    
    public var body: some View {
        ColumnView {
            if !isOtpStep {
                phoneInputSection()
            } else {
                otpInputSection()
            }
            
            if requestError.isNotBlank {
                Text(requestError)
                    .font(.system(size: 12))
                    .foregroundColor(Color(BaseTheme.baseRedColor))
                    .padding(.top, 4)
            }
            
            if errToShow.isNotBlank {
                Text(errToShow)
                    .font(.system(size: 12))
                    .foregroundColor(Color(BaseTheme.baseRedColor))
                    .padding(.top, 4)
            }
        }
        .onAppear {
            recomputePhoneError()
        }
        .onChange(of: localNumber) { _ in
            requestError = ""
            onValueChange(buildLebanonE164(localNumber, countryDial: countryDial))
            recomputePhoneError()
        }
        .sheet(isPresented: $showCountryDialog) {
            countryPickerSheet()
        }
    }
    
    // MARK: - Derived
    
    private var otpSize: Int {
        Int(contextAwareSigningModel.data.otpSize ?? 8)
    }
    
    private var otpType: Int {
        Int(contextAwareSigningModel.data.otpType ?? 1)
    }
    
    private var expiryMinutes: Double {
        contextAwareSigningModel.data.otpExpiryTime ?? 1.0
    }
    
    private var e164Phone: String {
        buildLebanonE164(localNumber, countryDial: countryDial)
    }
    
    private var searchableCountries: [CountryOptionSwift] {
        [
            CountryOptionSwift(
                code3: "LBN",
                code2: "LB",
                name: "Lebanon",
                dialCode: "+961"
            )
        ]
    }
    
    private var filteredCountries: [CountryOptionSwift] {
        if !userStartedTyping {
            return searchableCountries
        }
        
        return searchableCountries.filter { option in
            option.name.localizedCaseInsensitiveContains(searchQuery) ||
            option.code2.localizedCaseInsensitiveContains(searchQuery) ||
            option.code3.localizedCaseInsensitiveContains(searchQuery) ||
            option.dialCode.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    // MARK: - Main UI
    
    @ViewBuilder
    private func phoneInputSection() -> some View {
        HStack(spacing: 8) {
            Button {
                searchQuery = ""
                userStartedTyping = false
                showCountryDialog = true
            } label: {
                HStack {
                    Text("\(countryFlag) \(countryDial)")
                        .font(.system(size: 16))
                        .foregroundColor(Color(BaseTheme.baseTextColor))
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(BaseTheme.baseTextColor).opacity(0.8))
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(BaseTheme.fieldColor))
                )
            }
            .buttonStyle(.plain)
            .frame(width: 120)

            HStack(spacing: 10) {
                TextField(title, text: Binding(
                    get: { localNumber },
                    set: { raw in
                        let onlyDigits = raw.filter(\.isNumber)
                        localNumber = String(onlyDigits.prefix(8))
                    }
                ))
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(Color(BaseTheme.baseTextColor))
                .frame(maxWidth: .infinity)

                if phoneLooksValidLB(localNumber) {
                    Button {
                        sendOtp()
                    } label: {
                        ZStack {
                            if sendingOtp {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(Color(BaseTheme.baseTextColor))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Send OTP")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(BaseTheme.baseTextColor))
                            }
                        }
                        .frame(width: 86, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(BaseTheme.baseAccentColor))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(sendingOtp || !phoneLooksValidLB(localNumber))
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(BaseTheme.fieldColor))
            )
        }
    }
    
    @ViewBuilder
    private func otpInputSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("OTP (\(otpSize))", text: Binding(
                get: { isVerified ? e164Phone : otp },
                set: { raw in
                    guard !isVerified, !verifying else { return }
                    
                    requestError = ""
                    
                    let filtered = filterByOtpType(raw, otpType: otpType)
                    let limited = String(filtered.prefix(otpSize))
                    otp = limited
                    
                    if limited.count == otpSize, otpMatchesType(limited, otpType: otpType) {
                        verifyOtp()
                    }
                }
            ))
            .keyboardType(otpKeyboardType(otpType))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .disabled(isVerified)
            .foregroundColor(Color(BaseTheme.baseTextColor))
            .padding(.horizontal, 14)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(BaseTheme.fieldColor))
            )
            
            otpFooter()
        }
    }
    
    @ViewBuilder
    private func otpFooter() -> some View {
        HStack {
            if isVerified {
                Text("Verified successfully")
                    .font(.system(size: 12))
                    .foregroundColor(Color(BaseTheme.baseAccentColor))
            } else if verifying {
                Text("Otp verifying ...")
                    .font(.system(size: 12))
                    .foregroundColor(Color(BaseTheme.baseAccentColor))
            } else if sendingOtp {
                HStack(spacing: 6) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(BaseTheme.baseTextColor))
                        .scaleEffect(0.7)
                    
                    Text("Sending OTP...")
                        .font(.system(size: 12))
                        .foregroundColor(Color(BaseTheme.baseAccentColor))
                }
            } else {
                ResendOtpControl(expiryMinutes: expiryMinutes) {
                    resendOtp()
                }
            }
            
            Spacer()
        }
        .padding(.top, 6)
    }
    
    @ViewBuilder
    private func countryPickerSheet() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose code")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(BaseTheme.baseTextColor))
            
            TextField("Search...", text: $searchQuery)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 12)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(BaseTheme.fieldColor))
                )
                .foregroundColor(Color(BaseTheme.baseTextColor))
                .onChange(of: searchQuery) { _ in
                    userStartedTyping = true
                }
            
            ScrollView {
                VStack(spacing: 0) {
                    if filteredCountries.isEmpty {
                        Text("No results found")
                            .foregroundColor(Color(BaseTheme.baseTextColor).opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                    } else {
                        ForEach(filteredCountries, id: \.code2) { option in
                            HStack {
                                Text(flagEmoji(option.code2))
                                Text(option.dialCode)
                                    .foregroundColor(Color(BaseTheme.baseTextColor))
                                Text(option.name)
                                    .foregroundColor(Color(BaseTheme.baseTextColor))
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 12)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showCountryDialog = false
                                searchQuery = ""
                                userStartedTyping = false
                            }
                        }
                    }
                }
            }
            .frame(height: 220)
            
            Spacer()
        }
        .padding(16)
        .background(Color(BaseTheme.fieldColor))
    }
    
    // MARK: - Logic
    
    private func recomputePhoneError() {
        if localNumber.isNotBlank && !phoneLooksValidLB(localNumber) {
            errToShow = "Please enter a valid Lebanese number"
        } else {
            errToShow = ""
        }
    }
    
    private func sendOtp() {
        guard !sendingOtp else { return }
        guard phoneLooksValidLB(localNumber) else { return }
        guard let configModelObject = ConfigModelObject.shared.get() else { return }
        
        sendingOtp = true
        requestError = ""
        
        let req = RequestOtpModel(
            token: e164Phone,
            inputType: "PhoneNumberWithOtp",
            otpSize: otpSize,
            otpType: otpType,
            otpExpiryTime: expiryMinutes
        )
        
        OtpHelper.requestOtp(config: configModelObject, requestOtpModel: req) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    sendingOtp = false
                    isOtpStep = true
                    otp = ""
                    isVerified = false
                    requestError = ""
                }
            case .failure:
                DispatchQueue.main.async {
                    sendingOtp = false
                    requestError = "Failed to send OTP. Please try again."
                }
            }
        }
    }
    
    private func resendOtp() {
        sendOtp()
    }
    
    private func verifyOtp() {
        guard phoneLooksValidLB(localNumber) else { return }
        guard otp.count == otpSize else { return }
        guard let configModelObject = ConfigModelObject.shared.get() else { return }
        
        verifying = true
        requestError = ""
        
        let verifyReq = VerifyOtpRequestOtpModel(
            token: e164Phone,
            otp: otp,
            otpExpiryTime: expiryMinutes
        )
        
        OtpHelper.verifyOtp(config: configModelObject, verifyOtpRequestOtpModel: verifyReq) { result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    verifying = false
                    isVerified = success
                    
                    if success {
                        requestError = ""
                        onValid()
                    } else {
                        requestError = "Invalid OTP. Please try again."
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    verifying = false
                    isVerified = false
                    requestError = "Invalid OTP. Please try again."
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func otpMatchesType(_ value: String, otpType: Int) -> Bool {
        switch otpType {
        case 1:
            return value.allSatisfy { $0.isNumber }
        case 2:
            return value.allSatisfy { $0.isLetter || $0.isNumber }
        case 3:
            return value.allSatisfy { $0.isLetter }
        default:
            return true
        }
    }
    
    private func filterByOtpType(_ raw: String, otpType: Int) -> String {
        switch otpType {
        case 1:
            return raw.filter { $0.isNumber }
        case 2:
            return raw.filter { $0.isLetter || $0.isNumber }
        case 3:
            return raw.filter { $0.isLetter }
        default:
            return raw
        }
    }
    
    private func otpKeyboardType(_ otpType: Int) -> UIKeyboardType {
        switch otpType {
        case 1:
            return .numberPad
        case 2:
            return .asciiCapable
        case 3:
            return .default
        default:
            return .asciiCapable
        }
    }
}

// MARK: - Helpers

private struct CountryOptionSwift {
    let code3: String
    let code2: String
    let name: String
    let dialCode: String
}

private func phoneLooksValidLB(_ local: String) -> Bool {
    let digits = local.filter(\.isNumber)

    // keep leading 0 because your regex expects it (03, 70...)
    let pattern = "^(03|70|71|76|78|79|81)\\d{6}$"

    let regex = try! NSRegularExpression(pattern: pattern)
    let range = NSRange(location: 0, length: digits.utf16.count)

    return regex.firstMatch(in: digits, options: [], range: range) != nil
}

private func buildLebanonE164(_ local: String, countryDial: String = "+961") -> String {
    let digits = local.filter(\.isNumber)
    let normalized = digits.hasPrefix("0") ? String(digits.dropFirst()) : digits
    return countryDial + normalized
}



fileprivate extension String {
    var isNotBlank: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

fileprivate struct ColumnView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
    }
}
