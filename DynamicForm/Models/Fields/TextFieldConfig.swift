import Foundation

struct TextFieldConfig: Codable, Equatable {
    let id: String?
    let order: Int?
    let type: FieldType?
    let subtype: TextSubtype?
    let label: String?
    let placeholder: String?
    let supportingText: String?
    let defaultValue: String?
    let maxLength: Int?
    let errorMessage: String?
    let required: Bool?
    let regex: String?

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case subtype
        case label
        case placeholder
        case supportingText = "supporting_text"
        case defaultValue = "default_value"
        case maxLength = "max_length"
        case errorMessage = "error_message"
        case required
        case regex
    }
}
