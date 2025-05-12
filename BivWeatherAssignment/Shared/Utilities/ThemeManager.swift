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
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color("Primary")
        static let secondary = Color("Secondary")
        static let accent = Color("Accent")
        static let background = Color("Background")
        static let text = Color("Text")
        static let error = Color("Error")
        static let success = Color("Success")
        static let warning = Color("Warning")
    }
    
    // MARK: - Fonts
    struct Fonts {
        static let title = Font.system(size: 28, weight: .bold)
        static let headline = Font.system(size: 20, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 14, weight: .regular)
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
    var backgroundColor: Color {
        isDarkMode ? Colors.background : .white
    }
    
    /// Get text color
    var textColor: Color {
        isDarkMode ? .white : Colors.text
    }
}

// MARK: - View Extension
extension View {
    /// Apply theme to view
    func applyTheme() -> some View {
        self
            .preferredColorScheme(ThemeManager.shared.colorScheme)
            .background(ThemeManager.shared.backgroundColor)
            .foregroundColor(ThemeManager.shared.textColor)
    }
} 

