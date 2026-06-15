//
//  DynamicFormView.swift
//  DynamicForm
//
//  Created by Mrinmoy Kumar on 14/06/26.
//

import SwiftUI

struct DynamicFormView: View {
    @StateObject private var viewModel = FormViewModel()

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .loaded:
                if let config = viewModel.campaignFormConfig {
                    DynamicFormContentView(viewModel: viewModel, config: config)
                } else {
                    errorView(message: "no_form_available".localized)
                }
            case .error:
                errorView(message: viewModel.errorMessage ?? "something_went_wrong".localized)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("loading_form".localized)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.red)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Button("retry".localized) {
                viewModel.loadFormConfig(named: "campaign_form_config")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DynamicFormView()
}
