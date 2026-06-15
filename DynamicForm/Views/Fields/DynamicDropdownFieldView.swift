import SwiftUI

struct DynamicDropdownFieldView: View {
    @ObservedObject var viewModel: FormViewModel
    let field: DropdownFieldConfig

    private var options: [DropdownFieldOption] {
        field.options ?? []
    }

    private var allowsMultiple: Bool {
        field.allowMultiple == true
    }

    private var hasOptions: Bool {
        !options.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.fieldLabel(field.label, required: field.required))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(viewModel.textColor)

            Menu {
                ForEach(options) { option in
                    let optionID = option.id ?? option.label ?? ""
                    let optionLabel = option.label ?? optionID
                    let isSelected = viewModel.isDropdownOptionSelected(field: field, optionID: optionID)

                    Button {
                        viewModel.updateDropdownSelection(field: field, optionID: optionID)
                    } label: {
                        Label {
                            Text(optionLabel)
                        } icon: {
                            Image(systemName: menuIconName(isSelected: isSelected))
                        }
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(viewModel.dropdownDisplayText(for: field))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(viewModel.textColor)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(viewModel.borderColor)
                }
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(viewModel.borderColor, lineWidth: 1)
                )
                .opacity(hasOptions ? 1 : 0.65)
            }
            .buttonStyle(.plain)
            .disabled(!hasOptions)

            DynamicFieldErrorText(message: viewModel.errorMessage(for: .dropdown(field)), color: viewModel.errorColor)
        }
    }

    private func menuIconName(isSelected: Bool) -> String {
        guard allowsMultiple else {
            return isSelected ? "checkmark.circle.fill" : "circle"
        }
        return isSelected ? "checkmark.square.fill" : "square"
    }
}
