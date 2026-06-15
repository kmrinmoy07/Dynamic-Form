//
//  DynamicFormContentView.swift
//  DynamicForm
//
//  Created by Mrinmoy Kumar on 14/06/26.
//

import SwiftUI

struct DynamicFormContentView: View {
    @ObservedObject var viewModel: FormViewModel
    let config: CampaignFormConfig

    @FocusState private var focusedTextFieldID: String?

    var body: some View {
        ScrollViewReader { scrollProxy in
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    viewModel.backgroundColor
                        .ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if let title = config.formTitle {
                                Text(title)
                                    .font(.title2.bold())
                                    .foregroundStyle(viewModel.textColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            ForEach(Array(viewModel.displayableFields(from: config).enumerated()), id: \.offset) { _, field in
                                fieldView(for: field)
                            }

                            Button {
                                viewModel.save()
                            } label: {
                                Text("save".localized)
                                    .padding(.horizontal, 24)
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(20)
                    }

                    LinearGradient(
                        colors: [
                            viewModel.backgroundColor,
                            viewModel.backgroundColor.opacity(0.85),
                            viewModel.backgroundColor.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geometry.safeAreaInsets.top + 28)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
                }
            }
            .background(viewModel.backgroundColor.ignoresSafeArea())
            .onAppear {
                viewModel.prepareInitialValues(for: config, fallbackColor: viewModel.textColor)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if shouldShowNextButton {
                        Button("keyboard_next".localized) {
                            focusNextTextField(scrollProxy)
                        }
                    }

                    Spacer()

                    Button("keyboard_done".localized) {
                        focusedTextFieldID = nil
                    }
                }
            }
            .onChange(of: focusedTextFieldID) { focusedTextFieldID in
                scrollToFocusedField(focusedTextFieldID, with: scrollProxy)
            }
            .alert(
                "Form Submitted",
                isPresented: Binding(
                    get: {
                        viewModel.confirmationJSON != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.confirmationJSON = nil
                        }
                    }
                )
            ) {
                Button("OK") {
                    viewModel.confirmationJSON = nil
                }
            } message: {
                Text(viewModel.confirmationJSON ?? "")
            }
        }
    }

    @ViewBuilder
    private func fieldView(for field: FormField) -> some View {
        switch field {
        case .text(let fieldConfig):
            let focusID = viewModel.textFieldFocusID(for: fieldConfig)
            DynamicTextFieldView(
                viewModel: viewModel,
                field: fieldConfig,
                focusID: focusID,
                focusedFieldID: $focusedTextFieldID
            )
            .id(focusID)
        case .dropdown(let fieldConfig):
            DynamicDropdownFieldView(viewModel: viewModel, field: fieldConfig)
        case .checkbox(let fieldConfig):
            DynamicCheckboxFieldView(viewModel: viewModel, field: fieldConfig)
        case .toggle(let fieldConfig):
            DynamicToggleFieldView(viewModel: viewModel, field: fieldConfig)
        case .unknown:
            EmptyView()
        }
    }

    private var textFieldFocusIDs: [String] {
        viewModel.textFields(from: config).map { viewModel.textFieldFocusID(for: $0) }
    }

    private var shouldShowNextButton: Bool {
        let focusIDs = textFieldFocusIDs
        guard
            let focusedTextFieldID,
            let currentIndex = focusIDs.firstIndex(of: focusedTextFieldID)
        else {
            return focusIDs.count > 1
        }
        return currentIndex < focusIDs.index(before: focusIDs.endIndex)
    }

    private func focusNextTextField(_ scrollProxy: ScrollViewProxy) {
        let focusIDs = textFieldFocusIDs
        guard
            let focusedTextFieldID,
            let currentIndex = focusIDs.firstIndex(of: focusedTextFieldID)
        else {
            guard let firstFocusID = focusIDs.first else {
                return
            }
            self.focusedTextFieldID = firstFocusID
            scrollToFocusedField(firstFocusID, with: scrollProxy)
            return
        }

        let nextIndex = focusIDs.index(after: currentIndex)
        guard nextIndex < focusIDs.endIndex else {
            self.focusedTextFieldID = nil
            return
        }

        let nextFocusID = focusIDs[nextIndex]
        withAnimation(.easeInOut(duration: 0.2)) {
            self.focusedTextFieldID = nextFocusID
            scrollProxy.scrollTo(nextFocusID, anchor: .center)
        }
    }

    private func scrollToFocusedField(_ focusedTextFieldID: String?, with scrollProxy: ScrollViewProxy) {
        guard let focusedTextFieldID else {
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            scrollProxy.scrollTo(focusedTextFieldID, anchor: .center)
        }
    }
}

#Preview {
    DynamicFormContentView(
        viewModel: FormViewModel(),
        config: CampaignFormConfig(
            formTitle: "Campaign Setup",
            theme: FormTheme(
                backgroundColor: "#FFFFFF",
                textColor: "#111827",
                borderColor: "#D1D5DB",
                errorColor: "#B91C1C"
            ),
            fields: [
                .text(
                    TextFieldConfig(
                        id: "campaign_name",
                        order: 1,
                        type: .text,
                        subtype: .plain,
                        label: "Campaign Name",
                        placeholder: "e.g., Summer Sale",
                        supportingText: nil,
                        defaultValue: nil,
                        maxLength: 30,
                        errorMessage: nil,
                        required: true
                    )
                )
            ]
        )
    )
}
