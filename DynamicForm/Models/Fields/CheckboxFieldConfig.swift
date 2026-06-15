import Foundation

struct CheckboxFieldConfig: Codable, Equatable {
    let id: String?
    let order: Int?
    let type: FieldType?
    let label: String?
    let defaultValue: Bool?
    let errorMessage: String?
    let required: Bool?
    let metadata: [String: String]?
    let clickableTextColor: String?

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case label
        case defaultValue = "default_value"
        case errorMessage = "error_message"
        case required
        case metadata
        case clickableTextColor = "clickable_text_color"
    }
}
