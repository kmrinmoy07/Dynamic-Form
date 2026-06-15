import Foundation

enum FormField: Codable, Equatable {
    case text(TextFieldConfig)
    case dropdown(DropdownFieldConfig)
    case checkbox(CheckboxFieldConfig)
    case toggle(ToggleFieldConfig)
    case unknown(UnknownFieldConfig)

    enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(FieldType.self, forKey: .type)

        switch type {
        case .text:
            self = .text(try TextFieldConfig(from: decoder))
        case .dropdown:
            self = .dropdown(try DropdownFieldConfig(from: decoder))
        case .checkbox:
            self = .checkbox(try CheckboxFieldConfig(from: decoder))
        case .toggle:
            self = .toggle(try ToggleFieldConfig(from: decoder))
        case .unknown, nil:
            self = .unknown(try UnknownFieldConfig(from: decoder))
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let field):
            try field.encode(to: encoder)
        case .dropdown(let field):
            try field.encode(to: encoder)
        case .checkbox(let field):
            try field.encode(to: encoder)
        case .toggle(let field):
            try field.encode(to: encoder)
        case .unknown(let field):
            try field.encode(to: encoder)
        }
    }
}

extension FormField {
    var orderValue: Int {
        switch self {
        case .text(let config):
            return config.order ?? 0
        case .dropdown(let config):
            return config.order ?? 0
        case .checkbox(let config):
            return config.order ?? 0
        case .toggle(let config):
            return config.order ?? 0
        case .unknown(let config):
            return config.order ?? 0
        }
    }

    var shouldDisplayInUI: Bool {
        if case .unknown = self {
            return false
        }
        return true
    }
}
