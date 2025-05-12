import SwiftUI

/// Theme manager for handling app theming
class ThemeManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

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
    }

    /// Get color scheme
    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    /// Get background color
    var backgroundColor: UIColor {
        isDarkMode ? UIColor(named: "Background") ?? UIColor.systemBackground : .white
    }

    /// Get text color
    var textColor: UIColor {
        isDarkMode ? .white : UIColor(named: "Text") ?? UIColor.label
    }
    var primary: UIColor {
        isDarkMode ? UIColor(named: "Primary") ?? UIColor.systemBlue  : .white
    }
    var secondary: UIColor {
        isDarkMode ? UIColor(named: "Secondary") ?? UIColor.systemGray  : .white
    }
    var accent: UIColor {
        isDarkMode ? UIColor(named: "Accent") ?? UIColor.systemTeal  : .white
    }
    var error: UIColor {
        isDarkMode ? UIColor(named: "Error") ?? UIColor.systemRed  : .white
    }
    var success: UIColor {
        isDarkMode ? UIColor(named: "Success") ?? UIColor.systemGreen  : .white
    }
    var warning: UIColor {
        isDarkMode ? UIColor(named: "Warning") ?? UIColor.systemOrange  : .white
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
}
