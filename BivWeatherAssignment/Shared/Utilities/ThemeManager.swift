import SwiftUI
import UIKit

/// Theme manager for handling app theming
class ThemeManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    // MARK: - Properties
    static let shared = ThemeManager()

    // MARK: - Fonts
    struct Fonts {
        static let title = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let headline = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let caption = UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    // MARK: - Initialization
    private init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }

    // MARK: - Public Methods
    /// Toggle dark mode
    func toggleDarkMode() {
        isDarkMode.toggle()
        appDelegate?.configureAppAppearance()

    }

    /// Get color scheme
    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    /// Get background color
    var backgroundColor: UIColor {
        .clear
    }

    /// Get text color with high contrast
    var textColor: UIColor {
        .white
    }

    /// Primary brand color with good contrast in both modes
    var primary: UIColor {
        isDarkMode ? UIColor(hex: "#00CCFF") : UIColor(hex: "#0066CC")
    }

    /// Secondary color with sufficient contrast
    var secondary: UIColor {
        isDarkMode ? UIColor(hex: "#B3B3B3") : UIColor(hex: "#4D4D4D")
    }

    /// Accent color that pops in both modes
    var accent: UIColor {
        isDarkMode ? UIColor(hex: "#FF8000") : UIColor(hex: "#CC0099")
    }

    /// Error color with high visibility
    var error: UIColor {
        isDarkMode ? UIColor(hex: "#FF4D4D") : UIColor(hex: "#CC0000")
    }

    /// Success color that's clear in both modes
    var success: UIColor {
        isDarkMode ? UIColor(hex: "#4DE64D") : UIColor(hex: "#009900")
    }

    /// Warning color with good visibility
    var warning: UIColor {
        isDarkMode ? UIColor(hex: "#FFCC00") : UIColor(hex: "#CC6600")
    }
}

// MARK: - View Extension
extension View {
    /// Apply theme to view
    func applyTheme() -> some View {
        self
            .preferredColorScheme(ThemeManager.shared.colorScheme)
            .background(ThemeManager.shared.backgroundColor.toColor)
            .foregroundColor(ThemeManager.shared.textColor.toColor)
    }
}

// MARK: - UIColor Extension
extension UIColor {
    /// Convert UIColor to SwiftUI Color
    var toColor: Color {
        return Color(self)
    }

    /// Initialize color with hex string
    /// - Parameter hex: Hex color string (e.g. "#FF0000")
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    /// Convert color to hex string
    var hexString: String {
        let components = self.cgColor.components
        let red = components?[0] ?? 0
        let green = components?[1] ?? 0
        let blue = components?[2] ?? 0
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}
