import Foundation

struct DropdownFieldConfig: Codable, Equatable {
    let id: String?
    let order: Int?
    let type: FieldType?
    let label: String?
    let allowMultiple: Bool?
    let defaultValues: [String]?
    let errorMessage: String?
    let required: Bool?
    let options: [DropdownFieldOption]?

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case label
        case allowMultiple = "allow_multiple"
        case defaultValues = "default_values"
        case errorMessage = "error_message"
        case required
        case options
    }
}

struct DropdownFieldOption: Codable, Equatable, Identifiable {
    let id: String?
    let label: String?
}
