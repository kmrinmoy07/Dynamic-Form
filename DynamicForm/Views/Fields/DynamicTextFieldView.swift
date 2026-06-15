import SwiftUI

struct DynamicTextFieldView: View {
    @ObservedObject var viewModel: FormViewModel
    let field: TextFieldConfig
    let focusID: String
    let focusedFieldID: FocusState<String?>.Binding

    @State private var localValue = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.fieldLabel(field.label, required: field.required))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(viewModel.textColor)

            inputView

            if let supportingText = field.supportingText, !supportingText.isEmpty {
                Text(supportingText)
                    .font(.caption)
                    .foregroundStyle(viewModel.textColor.opacity(0.65))
            }

            if let maxLength = viewModel.maxLength(for: field) {
                Text("\(localValue.count)/\(maxLength)")
                    .font(.caption)
                    .foregroundStyle(viewModel.textColor.opacity(0.65))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            DynamicFieldErrorText(message: viewModel.errorMessage(for: .text(field)), color: viewModel.errorColor)
        }
        .onAppear {
            localValue = viewModel.updateTextValue(viewModel.textValue(for: field), for: field)
        }
        .onChange(of: localValue) { newValue in
            let updatedValue = viewModel.updateTextValue(newValue, for: field)
            guard updatedValue != newValue else {
                return
            }
            localValue = updatedValue
        }
    }

    @ViewBuilder
    private var inputView: some View {
        if field.subtype == .secure {
            SecureField("", text: $localValue, prompt: placeholderText)
                .focused(focusedFieldID, equals: focusID)
                .textFieldStyle(.plain)
                .foregroundStyle(viewModel.textColor)
                .tint(viewModel.textColor)
                .themedInputContainer(viewModel: viewModel)
        } else if field.subtype == .multiline {
            multilineEditor
        } else {
            TextField("", text: $localValue, prompt: placeholderText)
                .focused(focusedFieldID, equals: focusID)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(field.subtype == .uri ? .never : .sentences)
                .autocorrectionDisabled(field.subtype == .uri)
                .textFieldStyle(.plain)
                .foregroundStyle(viewModel.textColor)
                .tint(viewModel.textColor)
                .themedInputContainer(viewModel: viewModel)
        }
    }

    private var multilineEditor: some View {
        ZStack(alignment: .topLeading) {

            TextEditor(text: $localValue)
                .focused(focusedFieldID, equals: focusID)
                .foregroundStyle(viewModel.textColor)
                .tint(viewModel.textColor)
                .scrollContentBackground(.hidden)
                .background(viewModel.backgroundColor)
                .frame(minHeight: 96)
            
            if localValue.isEmpty, let placeholder = field.placeholder, !placeholder.isEmpty {
                Text(placeholder)
                    .foregroundStyle(viewModel.textColor.opacity(0.45))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
        }
        .padding(8)
        .background(viewModel.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(viewModel.borderColor, lineWidth: 1)
        )
    }

    private var placeholderText: Text {
        Text(field.placeholder ?? "")
            .foregroundColor(viewModel.textColor.opacity(0.45))
    }

    private var keyboardType: UIKeyboardType {
        switch field.subtype {
        case .number:
            return .decimalPad
        case .uri:
            return .URL
        default:
            return .default
        }
    }
}

private extension View {
    func themedInputContainer(viewModel: FormViewModel) -> some View {
        padding(12)
            .background(viewModel.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(viewModel.borderColor, lineWidth: 1)
            )
    }
}
