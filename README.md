# DynamicForm

DynamicForm is a SwiftUI sample project that builds a form UI from JSON configuration. The app decodes form metadata, theme values, and field definitions, then renders the correct SwiftUI controls dynamically.

## Architecture

The project follows MVVM.

1. Models decode the form config, theme, and fields.
2. The ViewModel loads JSON, prepares default values, filters invalid fields, stores dynamic state, validates input, and prepares the final JSON output.
3. SwiftUI views render the dynamic UI from the decoded model and delegate data handling back to the ViewModel.

## Structure

- `Models`: Root form config, theme, field enum, field configs, and field type enums.
- `ViewModels`: Form loading, state management, validation, dynamic values, and JSON output.
- `Views`: Form state container, form content view, and field-specific SwiftUI views.
- `Utilities`: Shared helpers such as localization and color parsing.
- `Resources`: JSON form configs and `Localizable.strings`.

## Product And Edge-Case Decisions

1. Missing IDs are skipped.
2. In case of duplicate IDs, only the first field is taken into consideration.
3. Fields with empty labels are skipped.
4. Dropdowns with no options are skipped.
5. Dropdown default values that are not present in the options are removed.
6. URLs entered without `https://` or `http://` are normalized by adding `https://`, and URLs are only accepted to be valid if it has a dot in middle with minimum of two characters in both side of the dot.
7. Invalid `max_length` values for text fields are ignored, so the text field becomes unlimited.
8. Secure fields require at least 8 characters, a number, letters, and a special symbol.
9. Editing a field clears its error.
10. Safe-area visibility is handled using a top gradient.
11. A character counter is shown when `max_length` is valid.
12. The keyboard toolbar supports `Next` and `Done`. On the last text field, only `Done` is shown and `Next` is hidden.
13. For text fields, the validation message is context-aware. If a required field is empty, the app shows the error_message provided in the JSON payload. However, if the user has entered a value and that value fails a specific validation rule, the app shows a more accurate error based on the failed validation reason.

## Dynamic State

The ViewModel stores field values in:

```swift
@Published var values: [String: Any] = [:]
@Published var errors: [String: String] = [:]
```

Dropdown state is stored as `[String]`, where each value is the selected option ID. The UI displays option labels, while the stored output keeps option IDs.

## Things I Got Stuck On

1. While implementing max length for plain text, the field initially allowed typing beyond the limit and only removed the extra text after focus changed. That happened because the view was using a direct ViewModel binding. For better UX, the text field now uses local view state and updates the ViewModel on change, so the user cannot type beyond the limit.
2. Printing the final JSON crashed when dropdown storage used `Set<String>`, because sets do not convert directly to JSON. Dropdown storage was changed to `[String]`.

## What I Would Improve With More Time

1. Add regex validation from JSON instead of hardcoded local validation rules.
2. Add a better confirmation UI instead of showing everything inside an alert.
3. Add support for more dynamic field types.
