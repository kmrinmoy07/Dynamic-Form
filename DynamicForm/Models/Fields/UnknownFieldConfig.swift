import Foundation

struct UnknownFieldConfig: Codable, Equatable {
    let id: String?
    let order: Int?
    let type: FieldType?
    let label: String?

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case type
        case label
    }
}
