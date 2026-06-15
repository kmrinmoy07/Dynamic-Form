import SwiftUI

extension String {
    var swiftUIColor: Color? {
        var hex = trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.first == "#" {
            hex.removeFirst()
        }

        guard let rgba = Self.rgbaComponents(from: hex) else {
            return nil
        }

        return Color(
            red: Double(rgba.red) / 255,
            green: Double(rgba.green) / 255,
            blue: Double(rgba.blue) / 255,
            opacity: Double(rgba.alpha) / 255
        )
    }

    func swiftUIColor(default fallback: Color) -> Color {
        swiftUIColor ?? fallback
    }

    private static func rgbaComponents(from hex: String) -> (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8)? {
        let expandedHex: String

        switch hex.count {
        case 3:
            expandedHex = hex.flatMap { [$0, $0] }.map(String.init).joined()
        case 4:
            expandedHex = hex.flatMap { [$0, $0] }.map(String.init).joined()
        case 6, 8:
            expandedHex = hex
        default:
            return nil
        }

        guard let value = UInt32(expandedHex, radix: 16) else {
            return nil
        }

        switch expandedHex.count {
        case 6:
            return (
                red: UInt8((value >> 16) & 0xFF),
                green: UInt8((value >> 8) & 0xFF),
                blue: UInt8(value & 0xFF),
                alpha: 0xFF
            )
        case 8:
            return (
                red: UInt8((value >> 24) & 0xFF),
                green: UInt8((value >> 16) & 0xFF),
                blue: UInt8((value >> 8) & 0xFF),
                alpha: UInt8(value & 0xFF)
            )
        default:
            return nil
        }
    }
}
