import SwiftUI
import UIKit

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func defaultShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    func centerInParent() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

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
    init(uiColor: UIColor) {
        self.init(uiColor)
    }

    var uiColor: UIColor {
        UIColor(self)
    }

    static let systemBackground = Color(UIColor.systemBackground)

    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)

    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

    static let label = Color(UIColor.label)

    static let secondaryLabel = Color(UIColor.secondaryLabel)

    static let tertiaryLabel = Color(UIColor.tertiaryLabel)

    static let separator = Color(UIColor.separator)

    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)

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
