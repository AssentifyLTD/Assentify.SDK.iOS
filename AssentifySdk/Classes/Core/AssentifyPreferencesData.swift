struct AssentifyPreferencesData {
    let apiKey: String
    let configModel: ConfigModel?
    let tenantIdentifier: String
    let interaction: String
    let environmentalConditions: EnvironmentalConditions?
    let processMrz: Bool
    let storeCapturedDocument: Bool
    let performLivenessDetection: Bool
    let storeImageStream: Bool
    let saveCapturedVideoID: Bool
    let saveCapturedVideoFace: Bool
}
