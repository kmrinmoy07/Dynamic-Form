import Foundation

struct CampaignFormConfig: Codable, Equatable {
    let formTitle: String?
    let theme: FormTheme?
    let fields: [FormField]?

    var sortedFields: [FormField] {
        (fields ?? []).sorted { $0.orderValue < $1.orderValue }
    }

    enum CodingKeys: String, CodingKey {
        case formTitle = "form_title"
        case theme
        case fields
    }

    init(formTitle: String? = nil, theme: FormTheme? = nil, fields: [FormField]? = nil) {
        self.formTitle = formTitle
        self.theme = theme
        self.fields = fields
    }
}
