import SwiftUI
import UIKit

// MARK: - View Extensions
extension View {
    /// Apply corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    /// Apply default shadow
    func defaultShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    /// Center view in parent
    func centerInParent() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    /// Apply loading state
    func loading(_ isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        )
    }

    /// Apply error state
    func error(_ error: Error?) -> some View {
        self.overlay(
            Group {
                if let error = error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        )
    }
}

// MARK: - Color Extensions
extension Color {
    /// Initialize Color from UIColor
    init(uiColor: UIColor) {
        self.init(uiColor)
    }

    /// Convert Color to UIColor
    var uiColor: UIColor {
        UIColor(self)
    }

    /// System background color
    static let systemBackground = Color(UIColor.systemBackground)

    /// System secondary background color
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)

    /// System tertiary background color
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

    /// System label color
    static let label = Color(UIColor.label)

    /// System secondary label color
    static let secondaryLabel = Color(UIColor.secondaryLabel)

    /// System tertiary label color
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)

    /// System separator color
    static let separator = Color(UIColor.separator)

    /// System grouped background color
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)

    /// System secondary grouped background color
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
}

// MARK: - Supporting Types
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
