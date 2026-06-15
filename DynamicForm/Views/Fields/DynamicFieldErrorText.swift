import SwiftUI

struct DynamicFieldErrorText: View {
    let message: String?
    let color: Color

    var body: some View {
        if let message, !message.isEmpty {
            Text(message)
                .font(.caption)
                .foregroundStyle(color)
        }
    }
}
