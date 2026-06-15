import Foundation

enum FieldType: Codable, Equatable {
    case text
    case dropdown
    case checkbox
    case toggle
    case unknown(String)

    var rawValue: String {
        switch self {
        case .text:
            return "TEXT"
        case .dropdown:
            return "DROPDOWN"
        case .checkbox:
            return "CHECKBOX"
        case .toggle:
            return "TOGGLE"
        case .unknown(let value):
            return value
        }
    }

    init(rawValue: String) {
        switch rawValue {
        case "TEXT":
            self = .text
        case "DROPDOWN":
            self = .dropdown
        case "CHECKBOX":
            self = .checkbox
        case "TOGGLE":
            self = .toggle
        default:
            self = .unknown(rawValue)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = FieldType(rawValue: (try? container.decode(String.self)) ?? "")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
