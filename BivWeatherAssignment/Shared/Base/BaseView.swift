import SwiftUI

/// Represents the different states a view can be in
enum ViewState: Equatable {
    case initial
    case loading
    case error(String)
    case success

    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.success, .success),
                (.initial, .initial):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

/// Base view that provides common functionality for all views
struct BaseView<Content: View>: View {
    // MARK: - Properties
    let content: Content
    @State private var viewState: ViewState = .success

    // MARK: - Initialization
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - Body
    var body: some View {
        content
            .overlay {
                switch viewState {
                case .loading:
                    ProgressView()
                case .error(let message):
                    VStack {
                        Text(message)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    default:
                        EmptyView()
                }
            }
            .onChange(of: viewState) { newState in
                if case .error = newState {
                    // Auto-dismiss error after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        viewState = .success
                    }
                }
            }
    }

    // MARK: - Public Methods
    /// Show loading state
    func showLoading() {
        viewState = .loading
    }

    /// Show error state
    func showError(_ error: Error) {
        viewState = .error(error.localizedDescription)
    }

    /// Show success state
    func showSuccess() {
        viewState = .success
    }
}

// MARK: - Preview Provider
struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        BaseView {
            Text("Hello, World!")
        }
    }
}
