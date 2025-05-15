import SwiftUI
import UIKit

struct ThemeManager {
    
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
    struct Color {
        static let backgroundColor: UIColor = .clear
        static let textColor: UIColor  = .white
        static let primary: UIColor = UIColor(hex: "#0066CC")
        static let secondary: UIColor  = UIColor(hex: "#4D4D4D")
        static let accentColor: UIColor = UIColor(hex: "#CC0099")
        static let errorColor: UIColor = UIColor(hex: "#CC0000")
        static let successColor: UIColor  = UIColor(hex: "#009900")
        static let warningColor: UIColor  = UIColor(hex: "#CC6600")
        static let shadowColor: UIColor = .white
    }
}

// MARK: - UIColor Extension
extension UIColor {
    
    var toColor: Color {
        return Color(self)
    }
    
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
    
    var hexString: String {
        let components = self.cgColor.components
        let red = components?[0] ?? 0
        let green = components?[1] ?? 0
        let blue = components?[2] ?? 0
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}
