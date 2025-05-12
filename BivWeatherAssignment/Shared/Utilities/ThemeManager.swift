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
        isDarkMode ? .black : .white
    }

    /// Get text color with high contrast
    var textColor: UIColor {
        isDarkMode ? .white : .black
    }

    /// Primary brand color with good contrast in both modes
    var primary: UIColor {
        isDarkMode ? UIColor(hex: 0x00CCFF) : UIColor(hex: 0x0066CC)
    }

    /// Secondary color with sufficient contrast
    var secondary: UIColor {
        isDarkMode ? UIColor(hex: 0xB3B3B3) : UIColor(hex: 0x4D4D4D)
    }

    /// Accent color that pops in both modes
    var accent: UIColor {
        isDarkMode ? UIColor(hex: 0xFF8000) : UIColor(hex: 0xCC0099)
    }

    /// Error color with high visibility
    var error: UIColor {
        isDarkMode ? UIColor(hex: 0xFF4D4D) : UIColor(hex: 0xCC0000)
    }

    /// Success color that's clear in both modes
    var success: UIColor {
        isDarkMode ? UIColor(hex: 0x4DE64D) : UIColor(hex: 0x009900)
    }

    /// Warning color with good visibility
    var warning: UIColor {
        isDarkMode ? UIColor(hex: 0xFFCC00) : UIColor(hex: 0xCC6600)
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

    /// Initialize color with hex value
    /// - Parameter hex: Hex color value (e.g. 0xFF0000 for red)
    convenience init(hex: Int) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }

    /// Initialize color with hex string
    /// - Parameter hexString: Hex color string (e.g. "#FF0000" or "FF0000" for red)
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    /// Convert color to hex string
    var hexString: String {
        let components = self.cgColor.components
        let r = components?[0] ?? 0
        let g = components?[1] ?? 0
        let b = components?[2] ?? 0
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
