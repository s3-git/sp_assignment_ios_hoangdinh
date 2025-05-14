import SwiftUI
import UIKit

/// A reusable toast component that works with both UIKit and SwiftUI
public final class Toast {
    // MARK: - Properties
    private static var window: UIWindow?
    private static var timer: Timer?
    private static var toastView: UIView?
    private static var toastLabel: UILabel?
    
    // MARK: - Configuration
    public struct Configuration {
        public var backgroundColor: UIColor
        public var textColor: UIColor
        public var font: UIFont
        public var cornerRadius: CGFloat
        public var duration: TimeInterval
        public var horizontalPadding: CGFloat
        public var verticalPadding: CGFloat
        public var bottomMargin: CGFloat
        
        public init(
            backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8),
            textColor: UIColor = .white,
            font: UIFont = .systemFont(ofSize: 14),
            cornerRadius: CGFloat = 8,
            duration: TimeInterval = 3.0,
            horizontalPadding: CGFloat = 16,
            verticalPadding: CGFloat = 12,
            bottomMargin: CGFloat = 20
        ) {
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.font = font
            self.cornerRadius = cornerRadius
            self.duration = duration
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
            self.bottomMargin = bottomMargin
        }
    }
    
    // MARK: - Public Methods
    
    /// Show toast message in UIKit
    /// - Parameters:
    ///   - message: Message to display
    ///   - configuration: Toast configuration
    public static func show(
        message: String,
        configuration: Configuration = .init()
    ) {
        DispatchQueue.main.async {
            cleanup()
            setupToast(message: message, configuration: configuration)
            animateIn()
            scheduleDismissal(duration: configuration.duration)
        }
    }
    
    /// Show toast message in SwiftUI
    /// - Parameters:
    ///   - message: Message to display
    ///   - configuration: Toast configuration
    public static func showInSwiftUI(
        message: String,
        configuration: Configuration = Configuration()
    ) {
        show(message: message, configuration: configuration)
    }
    
    // MARK: - Private Methods
    private static func setupToast(message: String, configuration: Configuration) {
        // Get the current window scene
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        
        // Create window
        let window = UIWindow(windowScene: windowScene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        
        // Create a root view controller
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .clear
        window.rootViewController = rootViewController
        window.isHidden = false
        self.window = window
        
        // Create toast view
        let toastView = UIView()
        toastView.backgroundColor = configuration.backgroundColor
        toastView.layer.cornerRadius = configuration.cornerRadius
        toastView.alpha = 0
        rootViewController.view.addSubview(toastView)
        self.toastView = toastView
        
        // Create label
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = configuration.textColor
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.font = configuration.font
        toastView.addSubview(toastLabel)
        self.toastLabel = toastLabel
        
        // Setup constraints
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor, constant: configuration.horizontalPadding),
            toastView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor, constant: -configuration.horizontalPadding),
            toastView.bottomAnchor.constraint(equalTo: rootViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -configuration.bottomMargin),
            
            toastLabel.topAnchor.constraint(equalTo: toastView.topAnchor, constant: configuration.verticalPadding),
            toastLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: configuration.horizontalPadding),
            toastLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -configuration.horizontalPadding),
            toastLabel.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -configuration.verticalPadding)
        ])
    }
    
    private static func animateIn() {
        UIView.animate(withDuration: 0.3) {
            self.toastView?.alpha = 1
        }
    }
    
    private static func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.toastView?.alpha = 0
        }, completion: { _ in
            completion()
        })
    }
    
    private static func scheduleDismissal(duration: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            dismiss()
        }
    }
    
    private static func dismiss() {
        animateOut {
            self.cleanup()
        }
    }
    
    private static func cleanup() {
        timer?.invalidate()
        timer = nil
        toastView?.removeFromSuperview()
        toastView = nil
        toastLabel = nil
        window = nil
    }
}
