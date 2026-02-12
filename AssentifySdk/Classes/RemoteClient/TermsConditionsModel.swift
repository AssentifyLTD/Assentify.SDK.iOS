import Foundation

public struct TermsConditionsModel: Codable {
    public let statusCode: Int
    public let data: TermsConditionsDataModel

    public init(statusCode: Int,
                data: TermsConditionsDataModel) {
        self.statusCode = statusCode
        self.data = data
    }
}

public struct TermsConditionsDataModel: Codable {
    public let header: String?
    public let subHeader: String?
    public let file: String?
    public let nextButtonTitle: String?
    public let confirmationRequired: Bool?

    public init(header: String?,
                subHeader: String?,
                file: String?,
                nextButtonTitle: String?,
                confirmationRequired: Bool?) {
        self.header = header
        self.subHeader = subHeader
        self.file = file
        self.nextButtonTitle = nextButtonTitle
        self.confirmationRequired = confirmationRequired
    }
}
