import SwiftUI

struct DynamicToggleFieldView: View {
    @ObservedObject var viewModel: FormViewModel
    let field: ToggleFieldConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: viewModel.toggleBinding(for: field)) {
                Text(viewModel.fieldLabel(field.label, required: field.required))
                    .foregroundStyle(viewModel.textColor)
            }
            .tint(.green)

            DynamicFieldErrorText(message: viewModel.errorMessage(for: .toggle(field)), color: viewModel.errorColor)
        }
    }
}
