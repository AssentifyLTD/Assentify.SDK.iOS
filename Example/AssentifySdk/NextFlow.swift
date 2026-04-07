import UIKit
import AVFoundation
import AssentifySdk



final class ViewController2: UIViewController, AssentifySdkDelegate, FlowDelegate {

    // MARK: - SDK
    private var assentifySdk: AssentifySdk?
    private var config: StartConfig?

    // MARK: - UI
    private let apiKeyField = UITextField()
    private let interactionHashField = UITextField()
    private let tenantIdField = UITextField()

    private let languageLabel = UILabel()

    // ✅ Dropdown language (UITextField + UIPickerView)
    private let languageDropdown = UITextField()
    private let languagePicker = UIPickerView()

    private let detectSwitch = UISwitch()
    private let guideSwitch = UISwitch()
    private let nfcSwitch = UISwitch()
    private let qrSwitch = UISwitch()

    private let startButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private let loader = UIActivityIndicatorView(style: .large)

    // MARK: - Data
    private let languages: [String] = [
        Language.English,
        Language.Arabic,
        Language.Azerbaijani,
        Language.Belarusian,
        Language.Georgian,
        Language.Korean,
        Language.Latvian,
        Language.Lithuanian,
        Language.Punjabi,
        Language.Russian,
        Language.Sanskrit,
        Language.Sindhi,
        Language.Thai,
        Language.Turkish,
        Language.Ukrainian,
        Language.Urdu,
        Language.Uyghur,
        Language.NON
    ]

    private var selectedLanguage: String = Language.NON

    private let accentHex = "#ffc400"
    private let textHex = "#000000"
    private let secondaryTextHex = "#ffffff"
    private let cardHex = "#f3f4f6"
    private let bgHex = "#ffffff"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        requestCameraPermissionIfNeeded()
        setupUI()
        setupLayout()
        setupKeyboardDismiss()
    }

    private func requestCameraPermissionIfNeeded() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in }
        case .denied, .restricted:
            return
        @unknown default:
            return
        }
    }

    // MARK: - UI Setup
    private func setupUI() {

        // Textfields style + black text
        [apiKeyField, interactionHashField, tenantIdField].forEach {
            $0.borderStyle = .roundedRect
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
            $0.clearButtonMode = .whileEditing
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true

            $0.textColor = .white
            $0.tintColor = .white
        }

        apiKeyField.placeholder = "API key"
        interactionHashField.placeholder = "Interaction hash"
        tenantIdField.placeholder = "Tenant Identifier"

        // default values (your demo)
         apiKeyField.text = "QwWzzKOYLkDzCLJ9lENlgvRQ1kmkKDv76KbJ9sPfr9Joxwj2DUuzC7htaZP89RqzgB9i9lHc4IpYOA7g"
          interactionHashField.text = "6A0001F3C7B0F99B14F5BB17B0694BE751F189ADB62A3811591E27558FC30503"
          tenantIdField.text = "2937c91f-c905-434b-d13d-08dcc04755ec"
        
        
        
        // Labels black
        languageLabel.text = "Language"
        languageLabel.font = .boldSystemFont(ofSize: 16)
        languageLabel.textColor = .black

        // ✅ Dropdown setup
        languageDropdown.borderStyle = .roundedRect
        languageDropdown.textColor = .white
        languageDropdown.tintColor = .white
        languageDropdown.placeholder = "Select Language"
        languageDropdown.heightAnchor.constraint(equalToConstant: 44).isActive = true

        languagePicker.dataSource = self
        languagePicker.delegate = self
        languageDropdown.inputView = languagePicker

        // default select NON
        if let idx = languages.firstIndex(of: Language.NON) {
            languagePicker.selectRow(idx, inComponent: 0, animated: false)
            selectedLanguage = languages[idx]
            languageDropdown.text = languages[idx]
        }

        // Toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneSelectingLanguage))
        done.tintColor = .black
      //  toolbar.setItems([UIBarButtonItem.flexibleSpace(), done], animated: false)
        languageDropdown.inputAccessoryView = toolbar

        // Switches
        detectSwitch.isOn = true
        guideSwitch.isOn = true
        nfcSwitch.isOn = false
        qrSwitch.isOn = false

        // Start button
        startButton.setTitle("Click to start", for: .normal)
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = UIColor(hex: "#FFDE00")
        startButton.layer.cornerRadius = 10
        startButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        startButton.addTarget(self, action: #selector(onStartTapped), for: .touchUpInside)
        
        clearButton.setTitle("Clear", for: .normal)
        clearButton.setTitleColor(.black, for: .normal)
        clearButton.backgroundColor = UIColor(hex: "#FFDE00")
        clearButton.layer.cornerRadius = 10
        clearButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        clearButton.addTarget(self, action: #selector(onClearTapped), for: .touchUpInside)
        
        
        
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.backgroundColor = UIColor(hex: "#FFDE00")
        backButton.layer.cornerRadius = 10
        backButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        backButton.addTarget(self, action: #selector(onBackTapped), for: .touchUpInside)

        
        

        // Loader
        loader.hidesWhenStopped = true
        loader.stopAnimating()
    }

    @objc private func doneSelectingLanguage() {
        languageDropdown.resignFirstResponder()
    }

    private func setupLayout() {
        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false

        // Switch rows
        let detectRow = makeSwitchRow(title: "Enable Detect", toggle: detectSwitch)
        let nfcRow = makeSwitchRow(title: "Enable Nfc", toggle: nfcSwitch)
        let qrRow = makeSwitchRow(title: "Enable Qr", toggle: qrSwitch)

        content.addArrangedSubview(spacer(height: 48))
        content.addArrangedSubview(apiKeyField)
        content.addArrangedSubview(interactionHashField)
        content.addArrangedSubview(tenantIdField)

        content.addArrangedSubview(spacer(height: 8))
        content.addArrangedSubview(languageLabel)
        content.addArrangedSubview(languageDropdown)

        content.addArrangedSubview(spacer(height: 4))
        content.addArrangedSubview(detectRow)
        content.addArrangedSubview(nfcRow)
        content.addArrangedSubview(qrRow)

        content.addArrangedSubview(spacer(height: 8))
        content.addArrangedSubview(startButton)
        content.addArrangedSubview(clearButton)
        content.addArrangedSubview(backButton)

        // loader centered under button
        let loaderWrap = UIView()
     

        loaderWrap.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        loaderWrap.addSubview(loader)
        loader.color = .black
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: loaderWrap.centerXAnchor),
            loader.topAnchor.constraint(equalTo: loaderWrap.topAnchor, constant: 18),
            loader.bottomAnchor.constraint(equalTo: loaderWrap.bottomAnchor, constant: -6)
        ])
        content.addArrangedSubview(loaderWrap)

        view.addSubview(content)

        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            content.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        ])
    }

    private func makeSwitchRow(title: String, toggle: UISwitch) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black

        let row = UIStackView(arrangedSubviews: [label, UIView(), toggle])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func spacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func onClearTapped(){
        self.assentifySdk?.clearFlow();
    }
   

    // MARK: - Start Flow
    @objc private func onStartTapped() {
        if loader.isAnimating { return } // avoid double tap

        dismissKeyboard()

        let apiKey = (apiKeyField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let interactionHash = (interactionHashField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let tenantIdentifier = (tenantIdField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        let cfg = StartConfig(
            apiKey: apiKey,
            interactionHash: interactionHash,
            tenantIdentifier: tenantIdentifier,
            language: selectedLanguage,
            enableDetect: detectSwitch.isOn,
            enableNfc: nfcSwitch.isOn,
            enableQr: qrSwitch.isOn
        )
        self.config = cfg

        guard !cfg.apiKey.isEmpty, !cfg.tenantIdentifier.isEmpty, !cfg.interactionHash.isEmpty else {
            showAlert(title: "Validation", message: "API key , Tenant Identifier , Interaction Hash are required.")
            return
        }

        // ✅ show loader immediately, hide later in success/error callbacks
        showLoader()

        let environmentalConditions = EnvironmentalConditions(
            enableDetect: cfg.enableDetect,
            CountDownNumbersColor: accentHex,
            HoldHandColor: accentHex,
            activeLiveType: ActiveLiveType.ACTIONS,
            activeLivenessCheckCount: 3,
            faceLivenessRetryCount: 2,
            minRam: 1,
            minCPUCores: 1
        )

        assentifySdk = AssentifySdk(
            apiKey: cfg.apiKey,
            tenantIdentifier: cfg.tenantIdentifier,
            interaction: cfg.interactionHash,
            environmentalConditions: environmentalConditions,
            assentifySdkDelegate: self,
            performActiveLivenessFace: false
        )
    }

    // MARK: - Loader
    private func showLoader() {
        startButton.isEnabled = false
        backButton.isEnabled = false
        clearButton.isEnabled = false
        loader.startAnimating()
    }

    private func hideLoader() {
        startButton.isEnabled = true
        backButton.isEnabled = true
        clearButton.isEnabled = true
        loader.stopAnimating()
    }
    
    @objc private func  onBackTapped() {
        dismiss(animated: true)
    }
    

    // MARK: - AssentifySdkDelegate
    func onAssentifySdkInitError(message: String) {
        DispatchQueue.main.async {
            self.hideLoader()
            self.showAlert(title: "AssentifySdk Init Error", message: message)
        }
    }

    func onAssentifySdkInitSuccess(configModel: ConfigModel) {
        DispatchQueue.main.async {
            self.hideLoader()

            guard let sdk = self.assentifySdk, let cfg = self.config else { return }
            AssentifySdkObject.shared.set(sdk)

            let customProperties: [String: Any] = [:]

            let flowEnvironmentalConditions = FlowEnvironmentalConditions(
                backgroundType: .color,
//                logoUrl: "https://image2url.com/r2/default/images/1769694393603-0afa5733-d9a5-4b0d-9134-868d3a750069.png",
//                textColor: self.textHex,
//                secondaryTextColor: self.secondaryTextHex,
//                backgroundCardColor: self.cardHex,
//                accentColor: self.accentHex,
//                backgroundColor: .solid(hex: self.bgHex),
//                clickColor: .solid(hex: self.accentHex),
//                language: cfg.language,
//                enableNfc: cfg.enableNfc,
//                enableQr: cfg.enableQr,
                blockLoaderCustomProperties: customProperties
            )

            sdk.startFlow(from: self, flowDelegate: self, flowEnvironmentalConditions: flowEnvironmentalConditions)
        }
    }

    // MARK: - onStepCompleted
    func onStepCompleted(stepModel: FlowCompletedModel) {
        DispatchQueue.main.async {
                print("onStepCompleted Step Data:", stepModel.stepData)
                print("onStepCompleted Submit Model:", stepModel.submitRequestModel as Any)
                print("---------------")
            
        }
    }
    
    // MARK: - FlowDelegate
    func onFlowCompleted(flowData: [FlowCompletedModel]) {
        DispatchQueue.main.async {
            for step in flowData {
                print("Step Data:", step.stepData)
                print("Submit Model:", step.submitRequestModel as Any)
                print("---------------")
            }
        }
    }
    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UIPickerView
extension ViewController2: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        languages.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        languages[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLanguage = languages[row]
        languageDropdown.text = languages[row]
    }
}

// MARK: - UIColor Hex helper
private extension UIColor {
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6 else { return nil }
        var rgb: UInt64 = 0
        guard Scanner(string: s).scanHexInt64(&rgb) else { return nil }
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

// MARK: - UIBarButtonItem helper
private extension UIBarButtonItem {
    static func flexibleSpace() -> UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}
