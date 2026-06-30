import UIKit
import AVFoundation
import AssentifySdk

struct StartConfig {
    let apiKey: String
    let language: String
    let enableDetect: Bool
    let enableNfc: Bool
    let enableQr: Bool
}

final class ViewController: UIViewController, AssentifySdkDelegate, FlowDelegate {

    // MARK: - SDK
    private var assentifySdk: AssentifySdk?
    private var config: StartConfig?

    // MARK: - UI
    private let apiKeyField = UITextField()

    private let languageLabel = UILabel()

    // ✅ Dropdown language (UITextField + UIPickerView)
    private let languageDropdown = UITextField()
    private let languagePicker = UIPickerView()

    private let detectSwitch = UISwitch()
    private let nfcSwitch = UISwitch()
    private let qrSwitch = UISwitch()

    private let startButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

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
        [apiKeyField].forEach {
            $0.borderStyle = .roundedRect
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
            $0.clearButtonMode = .whileEditing
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true

            $0.textColor = .white
            $0.tintColor = .white
        }

        apiKeyField.placeholder = "API key"

        // default values (your demo)
        //   apiKeyField.text = "3vFjQRfBVJL7PQ8APGeSfvNLlHGg7uG6O0GmCtN2e9iid2R51oVYsqJMpynavsALs51Lv3gb2HKknAu9Tgw"
        
        
        
        
        apiKeyField.text = "QwWzzKOYLkDzCLJ9lENlgvRQ1kmkKDv76KbJ9sPfr9Joxwj2DUuzC7htaZP89RqzgB9i9lHc4IpYOA7g"
        
       
        
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
        nfcSwitch.isOn = true
        qrSwitch.isOn = true

        // Start button
        startButton.setTitle("Click to start", for: .normal)
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = UIColor(hex: "#FFDE00")
        startButton.layer.cornerRadius = 10
        startButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        startButton.addTarget(self, action: #selector(onStartTapped), for: .touchUpInside)
 
        
        

//        // Next button
//        nextButton.setTitle("Next Flow", for: .normal)
//        nextButton.setTitleColor(.black, for: .normal)
//        nextButton.backgroundColor = UIColor(hex: "#FFDE00")
//        nextButton.layer.cornerRadius = 10
//        nextButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
//        nextButton.addTarget(self, action: #selector(onNextTapped), for: .touchUpInside)
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

        content.addArrangedSubview(spacer(height: 8))
        content.addArrangedSubview(languageLabel)
        content.addArrangedSubview(languageDropdown)

        content.addArrangedSubview(spacer(height: 4))
        content.addArrangedSubview(detectRow)
        content.addArrangedSubview(nfcRow)
        content.addArrangedSubview(qrRow)

        content.addArrangedSubview(spacer(height: 8))
        content.addArrangedSubview(startButton)
        content.addArrangedSubview(nextButton)


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
    
    
  
    
    @objc private func onNextTapped(){
        let vc = ViewController2()
       // self.assentifySdk?.clearFlow();
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    

    // MARK: - Start Flow
    @objc private func onStartTapped() {
        if loader.isAnimating { return } // avoid double tap

        dismissKeyboard()

        let apiKey = (apiKeyField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        let cfg = StartConfig(
            apiKey: apiKey,
            language: selectedLanguage,
            enableDetect: detectSwitch.isOn,
            enableNfc: nfcSwitch.isOn,
            enableQr: qrSwitch.isOn
        )
        self.config = cfg

        guard !cfg.apiKey.isEmpty else {
            showAlert(title: "Validation", message: "API key , Tenant Identifier , Interaction Hash are required.")
            return
        }

        // ✅ show loader immediately, hide later in success/error callbacks
        showLoader()

        let environmentalConditions = EnvironmentalConditions(
            enableDetect: cfg.enableDetect,
            CountDownNumbersColor: accentHex,
            HoldHandColor: "#e30505",
            activeLiveType: ActiveLiveType.ACTIONS,
            activeLivenessCheckCount: 3,
            faceLivenessRetryCount: 2,
            minRam: 1,
            minCPUCores: 1
        )
        
        var processJsonConfigFilePath: String = ""

        if let path = copyBundleFileToDocuments(fileName: "vardFile", fileExtension: "json") {
            processJsonConfigFilePath = path
        } else {
        }

        assentifySdk = AssentifySdk(
            apiKey: cfg.apiKey,
            configFileName: "NewSDK",
            environmentalConditions: environmentalConditions,
            assentifySdkDelegate: self,
            performActiveLivenessFace: false,
            //processJsonConfigFile: processJsonConfigFilePath
        )
    
    }

    // MARK: - Loader
    private func showLoader() {
        startButton.isEnabled = false
        nextButton.isEnabled = false
        loader.startAnimating()
    }

    private func hideLoader() {
        startButton.isEnabled = true
        nextButton.isEnabled = true
        loader.stopAnimating()
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

            var customProperties: [String: Any] = [:]
            
            customProperties["phoneNumber"] = "+963931646973"
            customProperties["email"] = "tariq.alskran@gmail.com"
            customProperties["city"] = "ANSAR"


            let flowEnvironmentalConditions = FlowEnvironmentalConditions(
                backgroundType: .color,
                //svgBackgroundImageUrl: "https://blob.assentify.com/v2/Document/XS3twSOb9sWXKsD2iszfGSfjTezaysDZ9K67sKJvqns=/Asset_1_background-20260519060448777.svg",
           
                
//                logoUrl: "https://i.postimg.cc/3xY0ybsp/icon-1-(1).png",
//                                  textColor: "#000000",
//                               secondaryTextColor: "#000000",
//                               backgroundCardColor: "#F2F2F2",
//
//                                  accentColor: "#833F89",
//                               backgroundColor: .solid(hex: "#FFFFFF"),
//                                  clickColor: .gradient(
//                                      colorsHex: ["#833F89", "#C82B47"],
//                                      angleDegrees: 90.0,
//                                      holdUntil: 0.4
//                                  ),
                
//                logoUrl : "https://image2url.com/r2/default/images/1774601396029-0d566673-586b-4d36-9f30-19704f88dba6.png",
//                svgBackgroundImageUrl: "https://qa.blob.assentify.com/v2/Document/6X1Zo1iR8OI13NUb2Gt9luIyX1aXodXzZpgpJDGcXlA=/Wave-20260512162501378.svg",
//
//                textColor:  "#FFFFFF",
//                secondaryTextColor: "#000000",
//                backgroundCardColor:  "#2C2C2E",
//                accentColor: "#E6BF00",
//                //backgroundColor: .solid(hex: "#2C2C2E"),
//                clickColor: .solid(hex:"#E6BF00"),
//
//
//
//
//
//                stepperType: StepperType.normal,
//                rangeStart: 30,
//                rangeEnd: 95,

                
                language: cfg.language,
                enableNfc: cfg.enableNfc,
                enableQr: cfg.enableQr,
                showCountDown: true,
                blockLoaderCustomProperties: customProperties,
                
            )

            // sdk.clearFlow();
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
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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


func copyBundleFileToDocuments(
    fileName: String,
    fileExtension: String = "json",
    destinationFileName: String? = nil
) -> String? {
    let fileManager = FileManager.default

    guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }

    let destFileName = destinationFileName ?? "\(fileName).\(fileExtension)"
    let destURL = docsURL.appendingPathComponent(destFileName)

    if fileManager.fileExists(atPath: destURL.path) {
        return destURL.path
    }

    guard let bundleURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
        return nil
    }

    do {
        let json = try String(contentsOf: bundleURL, encoding: .utf8)
        try json.write(to: destURL, atomically: true, encoding: .utf8)
        return destURL.path
    } catch {
        return nil
    }
}
