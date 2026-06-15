import SwiftUI

struct DynamicCheckboxFieldView: View {
    @ObservedObject var viewModel: FormViewModel
    let field: CheckboxFieldConfig

    var body: some View {
        let binding = viewModel.checkboxBinding(for: field)

        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Button {
                    binding.wrappedValue.toggle()
                } label: {
                    Image(systemName: binding.wrappedValue ? "checkmark.square.fill" : "square")
                        .font(.subheadline)
                        .foregroundStyle(binding.wrappedValue ? viewModel.textColor : viewModel.borderColor)
                        .frame(width: 18)
                }
                .buttonStyle(.plain)

                Text(attributedLabel)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environment(\.openURL, OpenURLAction { url in
                        .systemAction(url)
                    })
            }

            HStack(alignment: .top, spacing: 10) {
                Color.clear
                    .frame(width: 18, height: 0)

                DynamicFieldErrorText(message: viewModel.errorMessage(for: .checkbox(field)), color: viewModel.errorColor)
            }
        }
    }

    private var attributedLabel: AttributedString {
        var attributedString = AttributedString(viewModel.fieldLabel(field.label, required: field.required))
        attributedString.foregroundColor = viewModel.textColor

        for (substring, urlString) in field.metadata ?? [:] {
            guard
                let range = attributedString.range(of: substring),
                let url = URL(string: urlString)
            else {
                continue
            }

            attributedString[range].link = url
            attributedString[range].foregroundColor = linkColor
        }

        return attributedString
    }

    private var linkColor: Color {
        field.clickableTextColor?.swiftUIColor(default: viewModel.textColor) ?? viewModel.textColor
    }
}
