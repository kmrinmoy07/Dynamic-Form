//
//  FormViewModel.swift
//  DynamicForm
//
//  Created by Mrinmoy Kumar on 14/06/26.
//


import Foundation
import Combine
import SwiftUI

final class FormViewModel: ObservableObject {
    @Published var campaignFormConfig: CampaignFormConfig?
    @Published var viewState: ViewState = .loading
    @Published var errorMessage: String?
    @Published var values: [String: Any] = [:]
    @Published var errors: [String: String] = [:]
    @Published var confirmationJSON: String?

    var theme: FormTheme? {
        campaignFormConfig?.theme
    }

    var backgroundColor: Color {
        theme?.backgroundColor?.swiftUIColor(default: .white) ?? .white
    }

    var textColor: Color {
        theme?.textColor?.swiftUIColor(default: .primary) ?? .primary
    }

    var borderColor: Color {
        theme?.borderColor?.swiftUIColor(default: .gray.opacity(0.35)) ?? .gray.opacity(0.35)
    }

    var errorColor: Color {
        theme?.errorColor?.swiftUIColor(default: .red) ?? .red
    }

    init(
        jsonFileName: String = "all_in_one",
    ) {
        loadFormConfig(named: jsonFileName)
    }

    func loadFormConfig(named fileName: String) {
        viewState = .loading
        errorMessage = nil

        do {
            let data = try loadJSONData(named: fileName)
            campaignFormConfig = try JSONDecoder().decode(CampaignFormConfig.self, from: data)
            if let campaignFormConfig {
                values = [:]
                errors = [:]
                prepareInitialValues(for: campaignFormConfig, fallbackColor: textColor)
            }
            viewState = .loaded
        } catch {
            campaignFormConfig = nil
            errorMessage = error.localizedDescription.isEmpty ? "something_went_wrong".localized : error.localizedDescription
            viewState = .error
        }
    }

    private func loadJSONData(named fileName: String) throws -> Data {
        let normalizedFileName = fileName.replacingOccurrences(of: ".json", with: "")

        guard let url = Bundle.main.url(forResource: normalizedFileName, withExtension: "json") else {
            throw FormViewModelError.missingResource("\(normalizedFileName).json")
        }

        return try Data(contentsOf: url)
    }

    func displayableFields(from config: CampaignFormConfig) -> [FormField] {
        config.sortedFields.filter { field in
            field.shouldDisplayInUI
                && !isRequiredFieldWithMissingLabel(field)
                && !isDropdownWithMissingOptions(field)
        }
    }

    func textFields(from config: CampaignFormConfig) -> [TextFieldConfig] {
        displayableFields(from: config).compactMap { field in
            if case .text(let textField) = field {
                return textField
            }
            return nil
        }
    }

    func textFieldFocusID(for field: TextFieldConfig) -> String {
        fieldID(for: field)
    }

    func maxLength(for field: TextFieldConfig) -> Int? {
        guard let maxLength = field.maxLength, maxLength > 0 else {
            return nil
        }
        return maxLength
    }

    func prepareInitialValues(for config: CampaignFormConfig, fallbackColor: Color = .primary) {
        for field in displayableFields(from: config) {
            switch field {
            case .text(let field):
                let id = fieldID(for: field)
                if values[id] == nil {
                    values[id] = limitedTextValue(field.defaultValue ?? "", for: field)
                }
            case .dropdown(let field):
                let id = fieldID(for: field)
                if values[id] == nil {
                    values[id] = sanitizedDefaultDropdownValues(for: field)
                }
            case .checkbox(let field):
                let id = fieldID(for: field)
                if values[id] == nil {
                    values[id] = field.defaultValue ?? false
                }
            case .toggle(let field):
                let id = fieldID(for: field)
                if values[id] == nil {
                    values[id] = field.defaultValue ?? false
                }
            case .unknown:
                break
            }
        }
    }

    func textValue(for field: TextFieldConfig) -> String {
        let id = fieldID(for: field)
        return values[id] as? String ?? limitedTextValue(field.defaultValue ?? "", for: field)
    }

    
    func updateTextValue(_ value: String, for field: TextFieldConfig) -> String {
        let id = fieldID(for: field)
        let limitedValue = limitedTextValue(value, for: field)
        values[id] = limitedValue
        errors[id] = nil
        return limitedValue
    }

    func checkboxBinding(for field: CheckboxFieldConfig) -> Binding<Bool> {
        let fieldID = fieldID(for: field)

        return Binding(
            get: { self.values[fieldID] as? Bool ?? field.defaultValue ?? false },
            set: {
                self.values[fieldID] = $0
                self.errors[fieldID] = nil
            }
        )
    }

    func toggleBinding(for field: ToggleFieldConfig) -> Binding<Bool> {
        let fieldID = fieldID(for: field)

        return Binding(
            get: { self.values[fieldID] as? Bool ?? field.defaultValue ?? false },
            set: {
                self.values[fieldID] = $0
                self.errors[fieldID] = nil
            }
        )
    }

    func isDropdownOptionSelected(field: DropdownFieldConfig, optionID: String) -> Bool {
        selectedDropdownValues(for: field).contains(optionID)
    }

    func dropdownDisplayText(for field: DropdownFieldConfig) -> String {
        guard hasDropdownOptions(field) else {
            return "dropdown_no_options".localized
        }

        let selectedValues = selectedDropdownValues(for: field)
        let selectedLabels = (field.options ?? []).compactMap { option -> String? in
            let optionID = option.id ?? option.label ?? ""
            guard selectedValues.contains(optionID) else {
                return nil
            }
            return option.label ?? optionID
        }

        guard !selectedLabels.isEmpty else {
            return "select_option".localized
        }

        return selectedLabels.joined(separator: ", ")
    }

    func updateDropdownSelection(field: DropdownFieldConfig, optionID: String) {
        guard !optionID.isEmpty else {
            return
        }

        let id = fieldID(for: field)
        let allowsMultiple = field.allowMultiple == true
        var selectedValues = selectedDropdownValues(for: field)

        if allowsMultiple {
            if let selectedIndex = selectedValues.firstIndex(of: optionID) {
                selectedValues.remove(at: selectedIndex)
            } else {
                selectedValues.append(optionID)
            }
        } else {
            selectedValues = [optionID]
        }

        values[id] = selectedValues
        errors[id] = nil
    }

    func errorMessage(for field: FormField) -> String? {
        errors[fieldID(for: field)]
    }
    
    func save() {
        guard let campaignFormConfig else {
            errors = [:]
            return
        }
        
        var nextErrors: [String: String] = [:]
        
        for field in displayableFields(from: campaignFormConfig) {
            if let errorMessage = validate(field) {
                nextErrors[fieldID(for: field)] = errorMessage
            }
        }
        
        errors = nextErrors
        
        guard nextErrors.isEmpty else {
            confirmationJSON = nil
            return
        }
        
        confirmationJSON = finalValuesJSONString()
    }
    
    private func finalValuesJSONString() -> String {
        let printableValues = values.mapValues { value -> Any in
            if let stringArray = value as? [String] {
                return stringArray
            }
            
            if let stringValue = value as? String {
                return stringValue
            }
            
            if let boolValue = value as? Bool {
                return boolValue
            }
            
            if let intValue = value as? Int {
                return intValue
            }
            
            if let doubleValue = value as? Double {
                return doubleValue
            }
            
            if let setValue = value as? Set<String> {
                return Array(setValue).sorted()
            }
            
            return String(describing: value)
        }
        
        guard JSONSerialization.isValidJSONObject(printableValues) else {
            print("Final Form Values:")
            print(printableValues)
            return "\(printableValues)"
        }
        
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: printableValues,
                options: [.prettyPrinted, .sortedKeys]
            )
            
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "\(printableValues)"
            
            print("Final Form Values:")
            print(jsonString)
            
            return jsonString
        } catch {
            print("Final Form Values:")
            print(printableValues)
            return "\(printableValues)"
        }
    }

    func fieldLabel(_ label: String?, required: Bool?) -> String {
        guard required == true else {
            return label ?? ""
        }
        return "\(label ?? "") \("required_field_indicator".localized)"
    }

    private func limitedText(_ value: String, maxLength: Int?) -> String {
        guard let maxLength, value.count > maxLength else {
            return value
        }
        return String(value.prefix(maxLength))
    }

    private func limitedTextValue(_ value: String, for field: TextFieldConfig) -> String {
        let normalizedValue: String
        if field.subtype == .number {
            normalizedValue = numericTextValue(value)
        } else {
            normalizedValue = value
        }

        return limitedText(normalizedValue, maxLength: maxLength(for: field))
    }

    private func validate(_ field: FormField) -> String? {
        switch field {
        case .text(let field):
            return validateText(field)
        case .dropdown(let field):
            guard field.required == true else {
                return nil
            }
            return selectedDropdownValues(for: field).isEmpty
                ? validationMessage(field.errorMessage, fallback: "field_required".localized)
                : nil
        case .checkbox(let field):
            guard field.required == true else {
                return nil
            }
            return (values[fieldID(for: field)] as? Bool) == true
                ? nil
                : validationMessage(field.errorMessage, fallback: "field_required".localized)
        case .toggle(let field):
            guard field.required == true else {
                return nil
            }
            return (values[fieldID(for: field)] as? Bool) == true
                ? nil
                : validationMessage(field.errorMessage, fallback: "field_required".localized)
        case .unknown:
            return nil
        }
    }

    private func validateText(_ field: TextFieldConfig) -> String? {
        let fieldID = fieldID(for: field)
        let value = (values[fieldID] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if field.required == true && value.isEmpty {
            return validationMessage(field.errorMessage, fallback: "field_required".localized)
        }
        
        guard !value.isEmpty else {
            return nil
        }
        
        switch field.subtype {
        case .number:
            guard isNumber(value) else {
                return "number_invalid".localized
            }
            
        case .secure:
            guard isSecureText(value) else {
                return "secure_invalid".localized
            }
            
        case .uri:
            let normalizedValue = normalizedURLString(value)
            guard isURL(normalizedValue) else {
                return "uri_invalid".localized
            }
            
            values[fieldID] = normalizedValue
            
        default:
            break
        }
        
        if let regexError = validateRegexIfNeeded(field: field, value: values[fieldID] as? String ?? value) {
            return regexError
        }
        
        return nil
    }
    
    private func validateRegexIfNeeded(field: TextFieldConfig, value: String) -> String? {
        guard let regex = field.regex?.trimmingCharacters(in: .whitespacesAndNewlines),
              !regex.isEmpty else {
            return nil
        }
        guard value.range(of: regex, options: .regularExpression) != nil else {
            return "regex_invalid".localized
        }
        
        return nil
    }

    private func validationMessage(_ configuredMessage: String?, fallback: String) -> String {
        let trimmedMessage = configuredMessage?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedMessage?.isEmpty == false ? trimmedMessage! : fallback
    }

    private func selectedDropdownValues(for field: DropdownFieldConfig) -> [String] {
        let selectedValues = values[fieldID(for: field)] as? [String] ?? []
        let validOptionIDs = validDropdownOptionIDs(for: field)
        return selectedValues.reduce(into: []) { result, selectedValue in
            guard validOptionIDs.contains(selectedValue), !result.contains(selectedValue) else {
                return
            }
            result.append(selectedValue)
        }
    }

    private func hasDropdownOptions(_ field: DropdownFieldConfig) -> Bool {
        field.options?.isEmpty == false
    }

    private func sanitizedDefaultDropdownValues(for field: DropdownFieldConfig) -> [String] {
        let validOptionIDs = validDropdownOptionIDs(for: field)
        return (field.defaultValues ?? []).reduce(into: []) { result, defaultValue in
            guard validOptionIDs.contains(defaultValue), !result.contains(defaultValue) else {
                return
            }
            result.append(defaultValue)
        }
    }

    private func validDropdownOptionIDs(for field: DropdownFieldConfig) -> Set<String> {
        Set((field.options ?? []).compactMap { option in
            let optionID = option.id ?? option.label ?? ""
            return optionID.isEmpty ? nil : optionID
        })
    }

    private func isNumber(_ value: String) -> Bool {
        value.range(of: #"^\d+(\.\d+)?$"#, options: .regularExpression) != nil
    }

    private func numericTextValue(_ value: String) -> String {
        var hasDecimalSeparator = false
        var result = ""

        for character in value {
            if character.isNumber {
                result.append(character)
            } else if character == ".", !hasDecimalSeparator {
                hasDecimalSeparator = true
                result.append(character)
            }
        }

        return result
    }

    private func isSecureText(_ value: String) -> Bool {
        value.range(
            of: #"^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$"#,
            options: .regularExpression
        ) != nil
    }

    private func isURL(_ value: String) -> Bool {
        let normalizedValue = normalizedURLString(value)
        guard let url = URL(string: normalizedValue), let scheme = url.scheme, let host = url.host else {
            return false
        }
        return ["http", "https"].contains(scheme.lowercased()) && isValidHost(host)
    }

    private func isValidHost(_ host: String) -> Bool {
        let hostParts = host
            .lowercased()
            .split(separator: ".", omittingEmptySubsequences: false)
            .map(String.init)
        
        guard hostParts.count >= 2 else {
            return false
        }
        
        guard hostParts.allSatisfy({ $0.count >= 2 }) else {
            return false
        }
        
        return host.range(
            of: #"^[a-z0-9-]+(\.[a-z0-9-]+)+$"#,
            options: .regularExpression
        ) != nil
    }
    
    private func normalizedURLString(_ value: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            return trimmedValue
        }

        if trimmedValue.range(of: #"^[a-zA-Z][a-zA-Z0-9+\-.]*://"#, options: .regularExpression) != nil {
            return trimmedValue
        }

        return "https://\(trimmedValue)"
    }

    private func fieldID(for field: TextFieldConfig) -> String {
        fieldID(for: field.id, fallback: "text", disambiguator: "\(field.order ?? 0)_\(field.label ?? "")")
    }

    private func fieldID(for field: DropdownFieldConfig) -> String {
        fieldID(for: field.id, fallback: "dropdown", disambiguator: "\(field.order ?? 0)_\(field.label ?? "")")
    }

    private func fieldID(for field: CheckboxFieldConfig) -> String {
        fieldID(for: field.id, fallback: "checkbox", disambiguator: "\(field.order ?? 0)_\(field.label ?? "")")
    }

    private func fieldID(for field: ToggleFieldConfig) -> String {
        fieldID(for: field.id, fallback: "toggle", disambiguator: "\(field.order ?? 0)_\(field.label ?? "")")
    }

    private func fieldID(for field: FormField) -> String {
        switch field {
        case .text(let field):
            return fieldID(for: field)
        case .dropdown(let field):
            return fieldID(for: field)
        case .checkbox(let field):
            return fieldID(for: field)
        case .toggle(let field):
            return fieldID(for: field)
        case .unknown(let field):
            return fieldID(for: field.id, fallback: "unknown", disambiguator: "\(field.order ?? 0)_\(field.label ?? "")")
        }
    }

    private func fieldID(for id: String?, fallback: String, disambiguator: String) -> String {
        let trimmedID = id?.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedID?.isEmpty == false {
            return trimmedID!
        }
        return "\(fallback)_\(disambiguator)"
    }

    private func isRequiredFieldWithMissingLabel(_ field: FormField) -> Bool {
        fieldRequired(field) == true && fieldLabel(field).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func isDropdownWithMissingOptions(_ field: FormField) -> Bool {
        guard case .dropdown(let field) = field else {
            return false
        }
        return !hasDropdownOptions(field)
    }

    private func fieldRequired(_ field: FormField) -> Bool? {
        switch field {
        case .text(let field):
            return field.required
        case .dropdown(let field):
            return field.required
        case .checkbox(let field):
            return field.required
        case .toggle(let field):
            return field.required
        case .unknown:
            return false
        }
    }

    private func fieldLabel(_ field: FormField) -> String {
        switch field {
        case .text(let field):
            return field.label ?? ""
        case .dropdown(let field):
            return field.label ?? ""
        case .checkbox(let field):
            return field.label ?? ""
        case .toggle(let field):
            return field.label ?? ""
        case .unknown(let field):
            return field.label ?? ""
        }
    }
}


enum ViewState: Equatable {
    case loading
    case loaded
    case error
}

private enum FormViewModelError: LocalizedError {
    case missingResource(String)

    var errorDescription: String? {
        switch self {
        case .missingResource:
            return "json_file_not_found".localized
        }
    }
}
