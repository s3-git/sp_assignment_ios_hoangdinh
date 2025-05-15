import SwiftUI

enum ViewState: Equatable {
    case initial
    case loading
    case error(String)
    case empty
    case success
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
            case (.loading, .loading),
                (.success, .success),
                (.empty, .empty),
                (.initial, .initial):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
        }
    }
}
struct BaseView<Content: View>: View {
    // MARK: - Properties
    let content: Content
    
    // MARK: - Initialization
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Image(AppConstants.Assets.imgBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            content
               
        }
    }
    
}
