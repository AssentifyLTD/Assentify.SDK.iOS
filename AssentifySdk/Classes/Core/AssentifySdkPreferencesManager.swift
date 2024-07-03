import Foundation

class AssentifySdkPreferencesManager {
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveAssentifyPreferencesData(
        apiKey: String,
        configModel: ConfigModel,
        tenantIdentifier: String,
        interaction: String,
        environmentalConditions: EnvironmentalConditions,
        processMrz: Bool?,
        storeCapturedDocument: Bool?,
        performLivenessDetection: Bool?,
        storeImageStream: Bool?,
        saveCapturedVideoID: Bool?,
        saveCapturedVideoFace: Bool?
    ) {
        userDefaults.set(apiKey, forKey: AssentifyPreferencesKeys.API_KEY)
        if let configModelData = try? encoder.encode(configModel) {
            userDefaults.set(configModelData, forKey: AssentifyPreferencesKeys.CONFIG_MODEL)
        }
        userDefaults.set(tenantIdentifier, forKey: AssentifyPreferencesKeys.TENANT_IDENTIFIER)
        userDefaults.set(interaction, forKey: AssentifyPreferencesKeys.INTERACTION)
        if let environmentalConditionsData = try? encoder.encode(environmentalConditions) {
            userDefaults.set(environmentalConditionsData, forKey: AssentifyPreferencesKeys.ENVIRONMENTAL_CONDITIONS)
        }
        userDefaults.set(processMrz ?? false, forKey: AssentifyPreferencesKeys.PROCESS_MRZ)
        userDefaults.set(storeCapturedDocument ?? false, forKey: AssentifyPreferencesKeys.STORE_CAPTURED_DOCUMENT)
        userDefaults.set(performLivenessDetection ?? false, forKey: AssentifyPreferencesKeys.PERFORM_LIVENESS_DETECTION)
        userDefaults.set(storeImageStream ?? false, forKey: AssentifyPreferencesKeys.STORE_IMAGE_STREAM)
        userDefaults.set(saveCapturedVideoID ?? false, forKey: AssentifyPreferencesKeys.SAVE_CAPTURED_VIDEO_ID)
        userDefaults.set(saveCapturedVideoFace ?? false, forKey: AssentifyPreferencesKeys.SAVE_CAPTURED_VIDEO_FACE)
    }

    func getAssentifyPreferencesData() -> AssentifyPreferencesData? {
        guard let apiKey = userDefaults.string(forKey: AssentifyPreferencesKeys.API_KEY),
              let configModelData = userDefaults.data(forKey: AssentifyPreferencesKeys.CONFIG_MODEL),
              let tenantIdentifier = userDefaults.string(forKey: AssentifyPreferencesKeys.TENANT_IDENTIFIER),
              let interaction = userDefaults.string(forKey: AssentifyPreferencesKeys.INTERACTION),
              let environmentalConditionsData = userDefaults.data(forKey: AssentifyPreferencesKeys.ENVIRONMENTAL_CONDITIONS),
              let configModel = try? decoder.decode(ConfigModel.self, from: configModelData),
              let environmentalConditions = try? decoder.decode(EnvironmentalConditions.self, from: environmentalConditionsData)
        else {
            return nil
        }

        return AssentifyPreferencesData(
            apiKey: apiKey,
            configModel: configModel,
            tenantIdentifier: tenantIdentifier,
            interaction: interaction,
            environmentalConditions: environmentalConditions,
            processMrz: userDefaults.bool(forKey: AssentifyPreferencesKeys.PROCESS_MRZ),
            storeCapturedDocument: userDefaults.bool(forKey: AssentifyPreferencesKeys.STORE_CAPTURED_DOCUMENT),
            performLivenessDetection: userDefaults.bool(forKey: AssentifyPreferencesKeys.PERFORM_LIVENESS_DETECTION),
            storeImageStream: userDefaults.bool(forKey: AssentifyPreferencesKeys.STORE_IMAGE_STREAM),
            saveCapturedVideoID: userDefaults.bool(forKey: AssentifyPreferencesKeys.SAVE_CAPTURED_VIDEO_ID),
            saveCapturedVideoFace: userDefaults.bool(forKey: AssentifyPreferencesKeys.SAVE_CAPTURED_VIDEO_FACE)
        )
    }
}
