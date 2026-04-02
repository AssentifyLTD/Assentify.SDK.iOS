import SwiftUI

public struct OnCompleteScreen: View {

    let imageUrl: String
    let showStper: Bool
    let onNext: () -> Void

    let steps: [LocalStepModel] = LocalStepsObject.shared.get() ?? []

    public init(
        imageUrl: String,
        showStper: Bool = true,
        onNext: @escaping () -> Void,
    ) {
        self.imageUrl = imageUrl
        self.onNext = onNext
        self.showStper = showStper
    }

    // ✅ allowed keys (contains) like Kotlin
    private let allowedKeyParts: [(part: String, label: String)] = [
        ("OnBoardMe_IdentificationDocumentCapture_name", "First Name"),
        ("OnBoardMe_IdentificationDocumentCapture_surname", "Last Name"),
        ("OnBoardMe_IdentificationDocumentCapture_ID_FathersName", "Father Name"),
        ("OnBoardMe_IdentificationDocumentCapture_ID_MothersName", "Mother Name"),
        ("OnBoardMe_IdentificationDocumentCapture_Birth_Date", "Birth Date"),
        ("OnBoardMe_IdentificationDocumentCapture_Expiry_Date", "Expiry Date"),
        ("OnBoardMe_IdentificationDocumentCapture_Country", "Country"),
        ("OnBoardMe_IdentificationDocumentCapture_Nationality", "Nationality"),
        ("OnBoardMe_IdentificationDocumentCapture_Document_Number", "Document Number"),
        ("OnBoardMe_IdentificationDocumentCapture_IDType", "ID Type"),
        ("OnBoardMe_IdentificationDocumentCapture_ID_PlaceOfBirth", "Place of Birth"),
        ("OnBoardMe_IdentificationDocumentCapture_Document_Type", "Document Type"),
        ("OnBoardMe_IdentificationDocumentCapture_ID_CivilRegisterNumber", "Civil Register Number"),
        ("OnBoardMe_IdentificationDocumentCapture_ID_DateOfIssuance", "Date of Issuance"),
        ("OnBoardMe_IdentificationDocumentCapture_Sex", "Gender"),
        ("OnBoardMe_IdentificationDocumentCapture_ID_MaritalStatus", "Marital Status"),
        ("OnBoardMe_IdentificationDocumentCapture_ID_PlaceOfResidence", "Place of Residence"),
        ("OnBoardMe_IdentificationDocumentCapture_ID_Province", "Province"),
        ("OnBoardMe_IdentificationDocumentCapture_ID_Governorate", "Governorate")
    ]

    // MARK: - Helpers

    private func asCleanString(_ value: Any?) -> String? {
        guard let value else { return nil }
        let s = String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return nil }
        if s.lowercased() == "null" { return nil }
        return s
    }

    private func isAllowedKey(_ key: String) -> Bool {
        allowedKeyParts.contains {
            key.range(of: $0.part, options: [.caseInsensitive]) != nil
        }
    }
    
    private func keyLabel(_ key: String) -> String {
        allowedKeyParts.first {
            key.range(of: $0.part, options: [.caseInsensitive]) != nil
        }?.label ?? key
    }

    private func keyOrder(_ key: String) -> Int {
        allowedKeyParts.firstIndex {
            key.range(of: $0.part, options: [.caseInsensitive]) != nil
        } ?? Int.max
    }
    

   

    // MARK: - Data

    private var extractedMap: [String: String]? {
       return OnCompleteScreenData.shared.get()
    }

    private var dataRows: [(label: String, value: String)] {
        guard let extractedMap else { return [] }

        return extractedMap
            .filter { isAllowedKey($0.key) }
            .compactMap { (k, v) -> (key: String, label: String, value: String)? in
                
                // ❌ ignore images
                if k.range(of: "OnBoardMe_IdentificationDocumentCapture_Image", options: [.caseInsensitive]) != nil { return nil }
                if k.range(of: "OnBoardMe_IdentificationDocumentCapture_FaceCapture", options: [.caseInsensitive]) != nil { return nil }
                if k.range(of: "OnBoardMe_IdentificationDocumentCapture_ID_BackImage", options: [.caseInsensitive]) != nil { return nil }

                guard let value = asCleanString(v) else { return nil }

                return (key: k, label: keyLabel(k), value: value)
            }
            .sorted { keyOrder($0.key) < keyOrder($1.key) } // 🔥 your custom order
            .map { (label: $0.label, value: $0.value) }
    }

    private var imageUrls: [String] {
        guard let extractedMap else { return [] }
        var list: [String] = []

        // Front image
        if let front = extractedMap.first(where: { $0.key.range(of: "OnBoardMe_IdentificationDocumentCapture_Image", options: [.caseInsensitive]) != nil })?.value,
           let url = asCleanString(front) {
            list.append(url)
        }

        if let passport = NfcPassportResponseModelObject.shared.get(),
           let face = passport.passportExtractedModel?.faces?.first,
           !face.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            list.append(face)
        } else if let faceCapture = extractedMap.first(where: { $0.key.range(of: "OnBoardMe_IdentificationDocumentCapture_FaceCapture", options: [.caseInsensitive]) != nil })?.value,
                  let url = asCleanString(faceCapture) {
            list.append(url)
        }

        // Back image
        if let back = extractedMap.first(where: { $0.key.range(of: "OnBoardMe_IdentificationDocumentCapture_ID_BackImage", options: [.caseInsensitive]) != nil })?.value,
           let url = asCleanString(back) {
            list.append(url)
        }

        return list
    }

    // MARK: - UI

    public var body: some View {
        let fieldBg = Color(BaseTheme.fieldColor)
        let text = Color(BaseTheme.baseTextColor)
        let green = Color(BaseTheme.baseGreenColor)

        BaseBackgroundContainer {
            GeometryReader { geo in
                VStack(spacing: 0) {

                    if(showStper){
                        ProgressStepperView(
                            steps: steps,
                            bundle: .main
                        )
                        .padding(.top, 120)
                    }
                    

                    Spacer().frame(height: 16)

                    // ---- Images header container ----
                    if !imageUrls.isEmpty {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(fieldBg)
                            .overlay(
                                ImagesHeader(imageUrls: imageUrls)
                                    .padding(.vertical, 12)
                            )
                            .padding(.horizontal, 20)
                            .frame(height: 160)
                    }

                    Spacer().frame(height: 14)

                    // ---- List container (fixed height like Kotlin) ----
                    RoundedRectangle(cornerRadius: 20)
                        .fill(fieldBg)
                        .overlay(
                            ScrollView {
                                LazyVStack(spacing: 10) {
                                    ForEach(Array(dataRows.enumerated()), id: \.offset) { _, row in
                                        PrettyListRow(
                                            label: row.label,
                                            value: row.value,
                                            accentColor: green
                                        )
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                            }
                        )
                        .padding(.horizontal, 20)
                        .frame(height: geo.size.height / (showStper ? 2.3 : 1.8 ) )

                    Spacer().frame(height: 14)

                    BaseClickButton(
                        title: "Next",
                        cornerRadius: 28,
                        verticalPadding: 14,
                        enabled: true,
                        action: onNext
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .padding(.top, 6)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Images header (horizontal)

private struct ImagesHeader: View {
    let imageUrls: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(imageUrls.prefix(3), id: \.self) { url in
                    ZStack {
                   

                        SecureImage(imageUrl: url)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(8).padding(.horizontal,10)
                    }
                    .frame(width: 140, height: 120)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Row like Kotlin PrettyListRow

private struct PrettyListRow: View {
    let label: String
    let value: String
    let accentColor: Color

    var body: some View {
        let text = Color(BaseTheme.baseTextColor)
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 99)
                .fill(accentColor)
                .frame(width: 6, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(text.opacity(0.8))

                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(text)
                    .lineLimit(2)
            }

            Spacer(minLength: 10)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(accentColor)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(BaseTheme.fieldColor))   // single color
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )

    }
}
