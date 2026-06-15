import Foundation

enum TextSubtype: Codable, Equatable {
    case plain
    case number
    case secure
    case uri
    case multiline
    case unknown(String)

    var rawValue: String {
        switch self {
        case .plain:
            return "PLAIN"
        case .number:
            return "NUMBER"
        case .secure:
            return "SECURE"
        case .uri:
            return "URI"
        case .multiline:
            return "MULTILINE"
        case .unknown(let value):
            return value
        }
    }

    init(rawValue: String) {
        switch rawValue {
        case "PLAIN":
            self = .plain
        case "NUMBER":
            self = .number
        case "SECURE":
            self = .secure
        case "URI":
            self = .uri
        case "MULTILINE":
            self = .multiline
        default:
            self = .unknown(rawValue)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = TextSubtype(rawValue: (try? container.decode(String.self)) ?? "")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
