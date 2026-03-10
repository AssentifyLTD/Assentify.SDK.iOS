import SwiftUI
import UIKit

public struct SecureDropdown: View {

    public let title: String
    public let options: [String]
    public let page: Int
    public let flowController: FlowController

    @Binding public var field: DataEntryPageElement
    public let onValueChange: (String) -> Void

    // ✅ focus support from pager
    @Binding public var focusedFieldId: String?
    public let fieldId: String

    @State private var selected: String = ""
    @State private var err: String = ""
    @State private var expanded: Bool = false

    public init(
        title: String,
        options: [String],
        page: Int,
        field: Binding<DataEntryPageElement>,
        flowController: FlowController,
        focusedFieldId: Binding<String?>,
        fieldId: String,
        onValueChange: @escaping (String) -> Void
    ) {
        self.title = title
        self.options = options
        self.page = page
        self._field = field
        self.flowController = flowController
        self._focusedFieldId = focusedFieldId
        self.fieldId = fieldId
        self.onValueChange = onValueChange
        if (self.field.isHidden == true){
            loadDefaultIfNeeded()
        }
    }

    public var body: some View {
        if (self.field.isHidden == false){
        ZStack(alignment: .topLeading) {
       
            // tap outside to dismiss
            if expanded {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture { expanded = false }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(BaseTheme.baseTextColor))
                
                VStack(spacing: 0) {
                    
                    // Field (same pill style)
                    HStack(spacing: 10) {
                        Text(selected.isEmpty ? " " : selected)
                            .font(.system(size: 16))
                            .foregroundColor(Color(BaseTheme.baseTextColor))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Spacer(minLength: 8)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(BaseTheme.baseTextColor).opacity(0.8))
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                            .animation(.easeInOut(duration: 0.15), value: expanded)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(BaseTheme.fieldColor))
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedFieldId = fieldId
                        guard !isReadOnly else { return }
                        withAnimation(.easeInOut(duration: 0.15)) {
                            expanded.toggle()
                        }
                    }
                    
                    // Dropdown list (opens DOWN)
                    if expanded && !isReadOnly {
                        dropdownList()
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                
                if !err.isEmpty {
                    Text(err)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(BaseTheme.baseRedColor))
                }
            }
        }
        .onAppear {
            if let existing = field.value, !existing.isEmpty {
                selected = existing
            }
            loadDefaultIfNeeded()
            validate()

        }
        .onChange(of: field.value) { newValue in
            let v = newValue ?? ""
            if v != selected {
                selected = v
                validate()
            }
        }
        .onChange(of: field.inputKey) { _ in
            loadDefaultIfNeeded(force: true)
        }
        .onChange(of: field.languageTransformation) { _ in
            loadDefaultIfNeeded(force: true)
        }
        .onChange(of: focusedFieldId) { newValue in
            // if another field focused, close dropdown
            if newValue != fieldId {
                expanded = false
            }
        }
        }
    }

    // MARK: - Derived
    private var isReadOnly: Bool {
        (field.readOnly ?? false) || (getIsLocked())
    }
    
    private func getIsLocked()->Bool{
        let identifiers = field.inputPropertyIdentifierList ?? []
        return field.isLocked! && !identifiers.isEmpty
    }
    

    // MARK: - Dropdown UI
    @ViewBuilder
    private func dropdownList() -> some View {
        let radius: CGFloat = 16
        let maxHeight: CGFloat = 220

        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(options.indices, id: \.self) { idx in
                    let option = options[idx]

                    Button {
                        withAnimation(.easeInOut(duration: 0.12)) {
                            expanded = false
                        }
                        applyAndPersist(option)
                    } label: {
                        HStack {
                            Text(option)
                                .font(.system(size: 15))
                                .foregroundColor(Color(BaseTheme.baseTextColor))

                            Spacer()

                            if option == selected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(BaseTheme.baseAccentColor))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(BaseTheme.fieldColor)) // row bg
                    }
                    .buttonStyle(.plain)

                    // divider between rows (not after last)
                    if idx < options.count - 1 {
                        Divider()
                            .background(Color(BaseTheme.baseTextColor).opacity(0.10))
                            .padding(.leading, 14)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: maxHeight)
        .background(Color(BaseTheme.fieldColor))
        .clipShape(RoundedRectangle(cornerRadius: radius))   // ✅ important
        .overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(Color(BaseTheme.baseTextColor).opacity(0.08), lineWidth: 1)
        )
        .padding(.top, 6)
    }

    // MARK: - Default + Transformation (same logic)
    private func loadDefaultIfNeeded(force: Bool = false) {
        guard let key = field.inputKey else { return }

        if !force && !selected.isEmpty { return }

        if let existing = field.value, !existing.isEmpty, !force {
            selected = existing
            validate()
            return
        }

        let defaultValue = AssistedFormHelper.getDefaultValueValue(
            key,
            page,
            flowController: self.flowController
        ) ?? ""

        let langEnum = field.languageTransformation ?? 0
        if langEnum == 0 {
            applyAndPersist(defaultValue)
            return
        }

        guard let targetLang = field.targetOutputLanguage, !targetLang.isEmpty else {
            applyAndPersist(defaultValue)
            return
        }

        if selected.isEmpty || force {
            let dataList = [
                LanguageTransformationModel(
                    languageTransformationEnum: langEnum,
                    key: key,
                    value: defaultValue,
                    language: targetLang,
                    dataType: field.inputType
                )
            ]

            AssistedFormHelper.valueTransformation(
                language: targetLang,
                transformationModel: TransformationModel(languageTransformationModels: dataList)
            ) { data in
                DispatchQueue.main.async {
                    if let data {
                        self.applyAndPersist(data.value)
                    } else {
                        self.applyAndPersist(defaultValue)
                    }
                }
            }
        }
    }

    private func applyAndPersist(_ newValue: String) {
        guard let key = field.inputKey else { return }
        selected = newValue
        field.value = newValue
        AssistedFormHelper.changeValue(key, newValue, page)
        onValueChange(newValue)
        validate()
    }

    private func validate() {
        guard let key = field.inputKey else { return }
        err = AssistedFormHelper.validateField(key, page) ?? ""
    }
}
