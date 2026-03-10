import SwiftUI
import UIKit

public struct SecureDropdownWithDataSource: View {
    
    public let title: String
    public let page: Int
    public let flowController: FlowController
    
    @Binding public var field: DataEntryPageElement
    
    public let onValueChange: ([DataSourceAttribute], [String: String]) -> Void
    
    // ✅ focus support from pager
    @Binding public var focusedFieldId: String?
    public let fieldId: String
    
    @State private var dataSourceData: DataSourceData? = nil
    @State private var isLoading: Bool = false
    
    @State private var selected: [DataSourceAttribute] = []
    @State private var err: String = ""
    @State private var expanded: Bool = false
    
    public init(
        title: String,
        page: Int,
        field: Binding<DataEntryPageElement>,
        flowController: FlowController,
        focusedFieldId: Binding<String?>,
        fieldId: String,
        onValueChange: @escaping ([DataSourceAttribute], [String: String]) -> Void
    ) {
        self.title = title
        self.page = page
        self._field = field
        self.flowController = flowController
        self._focusedFieldId = focusedFieldId
        self.fieldId = fieldId
        self.onValueChange = onValueChange
        if (self.field.isHidden == true){
            loadDataSourceAndSelectDefault()
        }
    }
    
    public var body: some View {
        if (self.field.isHidden == false){
            ZStack(alignment: .topLeading) {
                
                // tap outside to dismiss menu
                if expanded {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture { expanded = false }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text(title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(BaseTheme.baseTextColor))
                    
                    if isLoading && dataSourceData == nil {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(BaseTheme.baseTextColor)))
                            .scaleEffect(1.0)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(BaseTheme.fieldColor))
                            )
                    } else {
                        VStack(spacing: 0) {
                            
                            // Field pill
                            HStack(spacing: 10) {
                                Text(displayValueForSelected())
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
                                guard dataSourceData != nil else { return }
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    expanded.toggle()
                                }
                            }
                            
                            // Dropdown list
                            if expanded && !isReadOnly, let ds = dataSourceData {
                                dropdownList(items: ds.items)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
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
                validate()
                loadDataSourceAndSelectDefault()
            }
            .onChange(of: field.inputKey) { _ in
                loadDataSourceAndSelectDefault(force: true)
            }
            .onChange(of: field.languageTransformation) { _ in
                loadDataSourceAndSelectDefault(force: true)
            }
            .onChange(of: focusedFieldId) { newValue in
                if newValue != fieldId { expanded = false }
            }
            .onChange(of: selectedDisplayValue()) { _ in
                validate()
            }
        }
    }
    
    // MARK: - Derived
    private var isReadOnly: Bool {
        (field.readOnly ?? false) || getIsLocked()
    }
    
    
    private func getIsLocked()->Bool{
        let identifiers = field.inputPropertyIdentifierList ?? []
        return field.isLocked! && !identifiers.isEmpty
    }
    
    // MARK: - UI helpers
    private func displayValueForSelected() -> String {
        let v = selectedDisplayValue()
        return v.isEmpty ? " " : v
    }
    
    private func selectedDisplayValue() -> String {
        selected.first(where: { $0.mappedKey == "Display Value" })?.value ?? ""
    }
    
    // MARK: - Dropdown list
    @ViewBuilder
    private func dropdownList(items: [DataSourceItem]) -> some View {
        let radius: CGFloat = 16
        let maxHeight: CGFloat = 220
        
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { idx in
                    let item = items[idx]
                    let optionText = item.dataSourceAttributes.first(where: { $0.mappedKey == "Display Value" })?.value ?? ""
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.12)) {
                            expanded = false
                        }
                        selectItem(item)
                    } label: {
                        HStack {
                            Text(optionText)
                                .font(.system(size: 15))
                                .foregroundColor(Color(BaseTheme.baseTextColor))
                            
                            Spacer()
                            
                            if optionText == selectedDisplayValue() {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(BaseTheme.baseAccentColor))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(BaseTheme.fieldColor))
                    }
                    .buttonStyle(.plain)
                    
                    if idx < items.count - 1 {
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
        .clipShape(RoundedRectangle(cornerRadius: radius))
        .overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(Color(BaseTheme.baseTextColor).opacity(0.08), lineWidth: 1)
        )
        .padding(.top, 6)
    }
    
    // MARK: - Selection + persist (Kotlin equivalent)
    private func selectItem(_ item: DataSourceItem) {
        guard let ds = dataSourceData else { return }
        selected = item.dataSourceAttributes
        
        // ✅ Persist like Kotlin when user picks
        AssistedFormHelper.changeValueSecureDropdownWithDataSource(
            key: field.inputKey!,
            dataSourceAttribute: selected,
            outputKeys: ds.outputKeys,
            page: page
        )
        
        onValueChange(selected, ds.outputKeys)
        validate()
    }
    
    // MARK: - Load datasource + apply default selection (Kotlin logic)
    private func loadDataSourceAndSelectDefault(force: Bool = false) {
        guard let key = field.inputKey, !key.isEmpty else { return }
        guard let endpointId = field.endpointId else { return }
        
        if isLoading && !force { return }
        
        isLoading = true
        
        let config = ConfigModelObject.shared.get()// adjust if your singleton differs
        let stepId = flowController.getCurrentStep()?.stepDefinition?.stepId ?? 0
        
        
        
        
        AssistedFormHelper.getDataSourceValues(
            apiKey: ApiKeyObject.shared.get()!,
            config: config!,
            elementIdentifier: field.elementIdentifier,
            stepId: stepId,
            endpointId: endpointId
        ) { result in
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.isLoading = false
                 
                    if let data = response.data {
                          self.dataSourceData = data
                      }
                    
                    guard let ds = self.dataSourceData else { return }
                    
                    let defaultRaw = AssistedFormHelper.getDefaultValueValue(
                        key,
                        self.page,
                        flowController: self.flowController
                    ) ?? ""
                    
                    let langEnum = self.field.languageTransformation ?? 0
                    if langEnum == 0 {
                        // pick by defaultRaw
                        if let matched = self.findItemByDisplayValue(ds: ds, display: defaultRaw) {
                            self.selected = matched.dataSourceAttributes
                            if !self.selected.isEmpty {
                                self.onValueChange(self.selected, ds.outputKeys)
                            }
                        }
                        self.validate()
                        return
                    }
                    
                    // transform default then pick
                    guard
                        let targetLang = self.field.targetOutputLanguage,
                        !targetLang.isEmpty
                    else {
                        if let matched = self.findItemByDisplayValue(ds: ds, display: defaultRaw) {
                            self.selected = matched.dataSourceAttributes
                            if !self.selected.isEmpty {
                                self.onValueChange(self.selected, ds.outputKeys)
                            }
                        }
                        self.validate()
                        return
                    }
                    
                    // only if nothing selected yet (or force)
                    if self.selected.isEmpty || force {
                        let dataList = [
                            LanguageTransformationModel(
                                languageTransformationEnum: langEnum,
                                key: key,
                                value: defaultRaw,
                                language: targetLang,
                                dataType: self.field.inputType
                            )
                        ]
                        
                        AssistedFormHelper.valueTransformation(
                            language: targetLang,
                            transformationModel: TransformationModel(languageTransformationModels: dataList)
                        ) { tData in
                            DispatchQueue.main.async {
                                let finalDisplay = tData?.value ?? defaultRaw
                                
                                if let matched = self.findItemByDisplayValue(ds: ds, display: finalDisplay) {
                                    self.selected = matched.dataSourceAttributes
                                } else if let fallback = self.findItemByDisplayValue(ds: ds, display: defaultRaw) {
                                    self.selected = fallback.dataSourceAttributes
                                }
                                
                                if !self.selected.isEmpty {
                                    AssistedFormHelper.changeValueSecureDropdownWithDataSource(
                                        key: self.field.inputKey!,
                                        dataSourceAttribute: self.selected,
                                        outputKeys: ds.outputKeys,
                                        page: self.page
                                    )
                                    self.onValueChange(self.selected, ds.outputKeys)
                                }
                                
                                self.validate()
                            }
                        }
                    } else {
                        self.validate()
                    }
                }
            case .failure(let err):
                print(err)
            }
            
        }
    }
    
    private func findItemByDisplayValue(ds: DataSourceData, display: String) -> DataSourceItem? {
        ds.items.first { item in
            item.dataSourceAttributes.first(where: { $0.mappedKey == "Display Value" })?.value == display
        }
    }
    
    // MARK: - Validation
    private func validate() {
        guard let key = field.inputKey else { return }
        err = AssistedFormHelper.validateField(key, page) ?? ""
    }
}
