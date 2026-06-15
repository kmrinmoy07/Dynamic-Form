import Foundation

struct ToggleFieldConfig: Codable, Equatable {
    let id: String?
    let order: Int?
    let type: FieldType?
    let label: String?
    let defaultValue: Bool?
    let errorMessage: String?
    let required: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case label
        case defaultValue = "default_value"
        case errorMessage = "error_message"
        case required
    }
}
