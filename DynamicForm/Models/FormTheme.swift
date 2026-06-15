import Foundation

struct FormTheme: Codable, Equatable {
    let backgroundColor: String?
    let textColor: String?
    let borderColor: String?
    let errorColor: String?

    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
    }
}
