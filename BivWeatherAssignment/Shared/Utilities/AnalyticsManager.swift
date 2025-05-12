import Foundation

/// Manager for handling app analytics
class AnalyticsManager {
    // MARK: - Properties
    static let shared = AnalyticsManager()
    
    // MARK: - Event Names
    enum Event: String {
        // App Lifecycle
        case appLaunch = "app_launch"
        case appBackground = "app_background"
        case appForeground = "app_foreground"
        
        // Weather
        case weatherRefresh = "weather_refresh"
        case weatherSearch = "weather_search"
        case weatherLocation = "weather_location"
        case weatherError = "weather_error"
        
        // Settings
        case settingsOpen = "settings_open"
        case settingsChange = "settings_change"
        case settingsDarkMode = "settings_dark_mode"
        
        // Permissions
        case permissionRequest = "permission_request"
        case permissionGranted = "permission_granted"
        case permissionDenied = "permission_denied"
    }
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    /// Track event
    /// - Parameters:
    ///   - event: The event to track
    ///   - parameters: Additional parameters for the event
    func track(_ event: Event, parameters: [String: Any]? = nil) {
        #if DEBUG
        print("📊 Analytics Event: \(event.rawValue)")
        if let parameters = parameters {
            print("Parameters: \(parameters)")
        }
        #endif
        
        // TODO: Implement actual analytics service
        // Example: Firebase Analytics
        // Analytics.logEvent(event.rawValue, parameters: parameters)
    }
    
    /// Track screen view
    /// - Parameters:
    ///   - screenName: The name of the screen
    ///   - screenClass: The class of the screen
    func trackScreenView(screenName: String, screenClass: String) {
        let parameters: [String: Any] = [
            "screen_name": screenName,
            "screen_class": screenClass
        ]
        
        #if DEBUG
        print("📱 Screen View: \(screenName)")
        print("Class: \(screenClass)")
        #endif
        
        // TODO: Implement actual analytics service
        // Example: Firebase Analytics
        // Analytics.logEvent(AnalyticsEventScreenView, parameters: parameters)
    }
    
    /// Track error
    /// - Parameters:
    ///   - error: The error to track
    ///   - context: Additional context for the error
    func trackError(_ error: Error, context: [String: Any]? = nil) {
        var parameters: [String: Any] = [
            "error_description": error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ]
        
        if let context = context {
            parameters.merge(context) { current, _ in current }
        }
        
        track(.weatherError, parameters: parameters)
    }
    
    /// Track user property
    /// - Parameters:
    ///   - name: The name of the property
    ///   - value: The value of the property
    func setUserProperty(_ name: String, value: String) {
        #if DEBUG
        print("👤 User Property: \(name) = \(value)")
        #endif
        
        // TODO: Implement actual analytics service
        // Example: Firebase Analytics
        // Analytics.setUserProperty(value, forName: name)
    }
} 