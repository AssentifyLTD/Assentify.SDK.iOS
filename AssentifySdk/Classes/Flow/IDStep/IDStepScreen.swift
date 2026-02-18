
import SwiftUI

public struct IDStepScreen: View {

    @Environment(\.dismiss) private var dismiss
    
    private func onBack() {
        flowController.backClick()
    }
    
    
    public func onNext() {
        self.flowController.push(HowToCaptureScreen(flowController: self.flowController))
    }
 
    private let steps = LocalStepsObject.shared.get()
    public let flowName: String
    public let baseLogoUrl: String?
    public let countriesInput: [TemplatesByCountry]

    @State private var countries: [TemplatesByCountry] = []
    @State private var selectedCountry: TemplatesByCountry?
    @State private var selectedTemplate: Templates?
    @State private var showIdsSheet = false

    
    private let flowController: FlowController


    public init(flowController: FlowController) {
        self.flowController = flowController
        self.flowName = ConfigModelObject.shared.get()!.flowName;
        self.baseLogoUrl = BaseTheme.baseLogo
        self.countriesInput = (AssentifySdkObject.shared.get()?.getTemplates(stepID: flowController.getCurrentStep()!.stepDefinition!.stepId))!
        OnCompleteScreenData.shared.clear();
        NfcPassportResponseModelObject.shared.clear();
        QrIDResponseModelObject.shared.clear();
    }

    
   

    public var body: some View {
        BaseBackgroundContainer { // <- your existing background container
            VStack(spacing: 0) {

                ProgressStepperView(steps: steps ?? [], bundle: .main)
                    .padding(.top, 20)

                // Middle content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        Text("Choose your country of residence")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(BaseTheme.baseTextColor))

                        CountryDropdownPill(
                            countryList: countries,
                            selected: selectedCountry,
                            onPick: { c in
                                selectedCountry = c
                                selectedTemplate = nil
                            }
                        )

                        Text("Select type of document")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(BaseTheme.baseTextColor))

                        if let country = selectedCountry {
                            DocumentPickerCards(
                                country: country,
                                selectedTemplate: selectedTemplate,
                                onSelect: { t in
                                    selectedTemplate = t
                                    SelectedTemplatesObject.shared.set(selectedTemplate!)
                                },
                                onViewMore: {
                                    showIdsSheet = true
                                }
                            )
                        }
                    }
                    .padding(16)
                } .padding(.horizontal, 5)

                // Bottom
                VStack(spacing: 10) {
                    Text("Only the presented IDs are supported and accepted by \(flowName). Make sure to provide one of them.")
                        .font(.system(size: 12, weight: .thin))
                        .foregroundStyle(Color(BaseTheme.baseTextColor))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                    BaseClickButton(title: "Next",  enabled: selectedTemplate != nil,) {
                        guard selectedTemplate != nil else { return }
                        onNext()
                    }.padding(.top,5)
                
                } .padding(.horizontal, 20)
            }.topBarBackLogo {
                onBack()
            }
        }.modifier(InterceptSystemBack(action: onBack))
        .onAppear {
            // add "Rest of the world" like Android
            var list = countriesInput
            list.append(
                TemplatesByCountry(
                    id: -1,
                    name: "Rest of the world",
                    sourceCountryCode: "",
                    flag: " ",
                    templates: []
                )
            )
            self.countries = list
            self.selectedCountry = list.first
        }
        .bottomSheet(
            isPresented: $showIdsSheet,
            height: sheetHeight(for: selectedCountry?.templates.count ?? 0)
        ) {
            if let country = selectedCountry {
                TemplatesBottomSheet(
                    title: "Supported IDs",
                    templates: country.templates,
                    onClose: { showIdsSheet = false }
                )
            }
        }
    }

    private func sheetHeight(for count: Int) -> CGFloat {
        // similar to Android logic: header + padding + rowHeight * count, capped to ~75% screen
        let header: CGFloat = 56
        let padding: CGFloat = 32
        let row: CGFloat = 88
        let calculated = header + padding + (row * CGFloat(max(count, 1)))
        let cap = UIScreen.main.bounds.height * 0.75
        return min(calculated, cap)
    }
}



////


struct CountryDropdownPill: View {
    let countryList: [TemplatesByCountry]
    let selected: TemplatesByCountry?
    let onPick: (TemplatesByCountry) -> Void

    var body: some View {
        Menu {
            ForEach(countryList, id: \.id) { c in
                Button(c.name) { onPick(c) }
            }
        } label: {
            HStack {
                Text(selected?.name ?? "Select country")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(Color(BaseTheme.baseTextColor))
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(BaseTheme.baseTextColor).opacity(0.8))
            }
            .padding(.horizontal, 18)
            .frame(height: 60)
            .background(Color(BaseTheme.fieldColor))
            .clipShape(RoundedRectangle(cornerRadius: 28))
        }
    }
}


////

struct DocumentPickerCards: View {
    let country: TemplatesByCountry
    let selectedTemplate: Templates?
    let onSelect: (Templates) -> Void
    let onViewMore: () -> Void

    private func isSelectedPassport() -> Bool { selectedTemplate?.id == -1 }
    private func isSelectedIDs() -> Bool { selectedTemplate != nil && selectedTemplate?.id != -1 }

    var body: some View {
        VStack(spacing: 10) {

            // Passport
            SelectCard(
                title: "Passport",
                subtitle: nil,
                selected: isSelectedPassport(),
                icon: "ic_passport.svg", // or Image(systemName:"passport") if you prefer
                onTap: {
                    onSelect(
                        
                        Templates(
                            id: -1,
                            sourceCountryFlag:"",
                            sourceCountryCode: "",
                            kycDocumentType: "Passport",
                            sourceCountry:"",
                            kycDocumentDetails: []
                        )
                    )
                }
            )

            // Supported IDs (only if templates exist)
            if !country.templates.isEmpty {
                SelectCard(
                    title: "Supported IDs",
                    subtitle: "View more",
                    selected: isSelectedIDs(),
                    icon: "id_card.svg", // or SF Symbol
                    onTap: {
                        onSelect(
                            Templates(
                                id: 1,
                                sourceCountryFlag:"",
                                sourceCountryCode:  country.sourceCountryCode,
                                kycDocumentType: "All IDs",
                                sourceCountry:"",
                                kycDocumentDetails: []
                            )
                        )
                    },
                    onSubtitleTap: onViewMore
                ).padding(.top,10)
            }
        }
    }
}

struct SelectCard: View {
    let title: String
    let subtitle: String?
    let selected: Bool
    let icon: String
    let onTap: () -> Void
    var onSubtitleTap: (() -> Void)? = nil

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 20) {   // ⬅️ more spacing
                
                // Bigger icon
                SVGAssetIcon(
                    name: icon,
                    size: CGSize(width: 64, height: 64),   // ⬅️ increased size
                    tintColor: UIColor(
                        selected
                        ? Color(BaseTheme.baseSecondaryTextColor)
                        : Color(BaseTheme.baseTextColor)
                    )
                )
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 6) {  // ⬅️ slightly more spacing
                    
                    Text(title)
                        .font(.system(size: 17, weight: .semibold)) // ⬅️ slightly bigger
                        .foregroundStyle(
                            selected
                            ? Color(BaseTheme.baseSecondaryTextColor)
                            : Color(BaseTheme.baseTextColor)
                        )

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(
                                selected
                                ? Color(BaseTheme.baseSecondaryTextColor)
                                : Color(BaseTheme.baseTextColor)
                            )
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(
                                        selected
                                        ? Color(BaseTheme.baseSecondaryTextColor)
                                        : Color(BaseTheme.baseTextColor)
                                    )
                                    .offset(y: 4),
                                alignment: .bottom
                            )
                            .onTapGesture {
                                onSubtitleTap?()
                            }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)   // ⬅️ more horizontal breathing
            .padding(.vertical, 26)     // ⬅️ slightly reduced from 30 (more balanced)
            .frame(maxWidth: .infinity)
            .background(
                selected
                ? Color(BaseTheme.baseAccentColor)
                : Color(BaseTheme.fieldColor)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20)) // ⬅️ smoother radius
            .shadow(
                color: .black.opacity(0.08),
                radius: 6,
                y: 3
            )
        }
        .buttonStyle(.plain)
    }
}


////


struct TemplatesBottomSheet: View {
    let title: String
    let templates: [Templates]
    let onClose: () -> Void

    var body: some View {
        BaseBackgroundContainer {
            VStack(alignment: .leading, spacing: 12) {

                HStack {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(BaseTheme.baseTextColor))

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(BaseTheme.baseTextColor))
                            .padding(10)
                            .background(Color(BaseTheme.fieldColor))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(templates, id: \.id) { t in
                            TemplateRow(template: t)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
}

struct TemplateRow: View {
    let template: Templates

    var iconUrl: String? {
        template.kycDocumentDetails.first?.templateSpecimen.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HStack(spacing: 12) {

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(BaseTheme.fieldColor))
                    .frame(width: 60, height: 60)

                if let iconUrl, !iconUrl.isEmpty, let url = URL(string: iconUrl) {
                    AsyncImage(url: url) { img in
                        img.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                }
            }

            Text(template.kycDocumentType)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(BaseTheme.baseTextColor))
                .lineLimit(2)

            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color(BaseTheme.fieldColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
    }
}
////

public struct BottomSheetOverlay<SheetContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    let height: CGFloat
    let sheetContent: () -> SheetContent

    public func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                // dim background
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }

                VStack {
                    Spacer()

                    sheetContent()
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
                .animation(.easeInOut(duration: 0.22), value: isPresented)
            }
        }
    }
}

public extension View {
    func bottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        height: CGFloat,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(BottomSheetOverlay(isPresented: isPresented, height: height, sheetContent: content))
    }
}
