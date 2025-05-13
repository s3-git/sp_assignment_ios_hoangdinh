# Weather App

A modern iOS weather application that allows users to search for cities and view their weather information. Built with a focus on clean architecture, maintainability, and performance.

## Features

### City Search
- Real-time city search with intelligent debouncing (500ms)
- Smart history management (max 10 recent cities)
- Persistent storage with encryption
- Comprehensive empty state handling
- Voice search support

### Weather Details
- Real-time weather conditions
- Dynamic temperature units (°C/°F)
- Detailed atmospheric conditions
  - Humidity
  - Wind speed and direction
  - Pressure
  - Visibility
- Animated weather icons
- Location details with maps integration
- Pull-to-refresh with custom animations

### Technical Features
- Hybrid architecture (UIKit + SwiftUI)
- Clean MVVM implementation
- Comprehensive error handling with recovery
- Multi-level caching strategy
  - Memory cache (1 minute)
  - Disk cache (1 hour)
- Zero external dependencies
- Full offline support
- Extensive logging system
- Analytics ready

## Architecture

### Core Components

#### Feature Modules
- **Home**: 
  - UIKit-based city search
  - Custom animations
  - Voice input support
  - History management
- **City**: 
  - SwiftUI-based weather view
  - Dynamic updates
  - Custom transitions
  - Offline support

#### Core Services
- **WeatherService**: 
  - Protocol-based API client
  - Response validation
  - Automatic retry
  - Certificate pinning
- **RecentCitiesService**: 
  - Thread-safe history management
  - Encrypted storage
  - Migration support
- **ErrorHandlingService**: 
  - Comprehensive error types
  - Recovery strategies
  - User-friendly messages

#### Base Components
- **BaseViewModel**: 
  - Thread-safe state management
  - Memory leak prevention
  - Automatic resource cleanup
- **BaseView**: 
  - SwiftUI view lifecycle
  - Memory management
  - Accessibility support
- **BaseViewController**: 
  - UIKit lifecycle management
  - Memory optimization
  - State restoration

### Design Patterns
- MVVM with clean architecture
- Coordinator for navigation
- Repository for data access
- Observer using Combine
- Protocol-oriented design
- Dependency injection

## Error Handling

### Error Types
- Network Errors (with retry)
- Data Persistence Errors
- City Search Errors
- Weather Data Errors
- UserDefaults Errors
- Validation Errors

### Error Recovery
- Automatic retry with backoff
- Cached data fallback
- User-friendly messages
- Guided recovery steps
- Comprehensive logging
- Analytics tracking

## Data Flow

### City Search
1. User input processing
2. Smart debouncing (500ms)
3. API request with validation
4. Response caching
5. Error handling with recovery
6. UI update with animations

### Weather Details
1. City selection handling
2. History update (thread-safe)
3. Weather data fetch
4. Multi-level caching
5. Offline fallback
6. Dynamic UI updates

## Dependencies

### Native Frameworks
- UIKit (UI components)
- SwiftUI (Modern views)
- Combine (Reactive programming)
- Foundation (Core utilities)
- CoreLocation (Location services)
- MapKit (Map integration)

### Zero External Dependencies
- Custom networking layer
- Built-in caching system
- Native reactive programming

## Setup & Installation

1. Clone the repository
2. Open BivWeatherAssignment.xcodeproj
3. Configure Environment.plist
4. Add API key securely
5. Build and run

### API Key Setup
1. Create Environment.plist
2. Add API_KEY entry
3. Set OpenWeatherMap key
4. Secure key storage

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_KEY</key>
    <string>YOUR_API_KEY</string>
</dict>
</plist>
```

## Security

### Data Protection
- Secure storage implementation
- API key encryption
- Network security measures
- Input validation
- Certificate pinning

## Testing

### Comprehensive Testing
- Unit tests (core logic)
- UI tests (critical flows)
- Performance tests
- Memory leak detection
- Network mocking

## Version Control

### Best Practices
- Feature branching
- Semantic versioning
- Clean commit history
- Code review process
- CI/CD integration

## License

This project is licensed under the MIT License.

## Contact

For questions or feedback, please contact the development team. 