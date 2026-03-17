enum ComparisonOperatorSplit {
    case equal
    case notEqual
    case greaterThan
    case greaterThanOrEqual
    case lessThan
    case lessThanOrEqual
    case contains
    case startsWith
    case endsWith
    
    static func from(_ value: Int?) -> ComparisonOperator {
        switch value {
        case 0: return .equal
        case 1: return .notEqual
        case 2: return .greaterThan
        case 3: return .greaterThanOrEqual
        case 4: return .lessThan
        case 5: return .lessThanOrEqual
        case 6: return .contains
        case 7: return .startsWith
        case 8: return .endsWith
        default: return .equal
        }
    }
}
