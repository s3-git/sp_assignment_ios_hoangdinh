import Combine
import SwiftUI
class KeyboardManager: ObservableObject {
    // MARK: - Published Properties
    @Published var keyboardHeight: CGFloat = 0
    @Published var isKeyboardVisible = false

    // MARK: - Properties
    static let shared = KeyboardManager()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private init() {
        setupKeyboardObservers()
    }

    // MARK: - Private Methods
    private func setupKeyboardObservers() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardWillShow(notification)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardWillHide(notification)
            }
            .store(in: &cancellables)
    }

    private func handleKeyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        keyboardHeight = keyboardFrame.height
        isKeyboardVisible = true
    }

    private func handleKeyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
        isKeyboardVisible = false
    }
}

// MARK: - View Extension
extension View {
    func keyboardAware() -> some View {
        self.modifier(KeyboardAwareModifier())
    }
}

// MARK: - KeyboardAwareModifier
struct KeyboardAwareModifier: ViewModifier {
    @StateObject private var keyboardManager = KeyboardManager.shared

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardManager.keyboardHeight)
            .animation(.easeOut(duration: 0.16), value: keyboardManager.keyboardHeight)
    }
}

// MARK: - View Extension
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func hideKeyboardOnTapOutside() -> some View {
        self.onTapGesture {
            dismissKeyboard()
        }
    }
}
