# Weather App

A modern iOS weather application that allows users to search for cities and view their weather information.

## Features

### City Search
- Real-time city search with debouncing
- Recent cities history (max 10)
- Persistence across app launches
- Empty state handling

### Weather Details
- Current weather conditions
- Temperature (°C and °F)
- Humidity
- Weather description
- Weather icon
- Location details

### Technical Features
- UIKit + SwiftUI hybrid implementation
- MVVM architecture
- Comprehensive error handling
- Response caching (1-minute expiry)
- No external dependencies

## Architecture

### Core Components

#### Feature Modules
- **Home**: UIKit-based city search and listing
- **City**: SwiftUI-based weather details view

#### Core Services
- **WeatherService**: Handles API communication
- **RecentCitiesService**: Manages recently viewed cities
- **ErrorHandlingService**: Centralized error management

#### Base Components
- **BaseViewModel**: Common ViewModel functionality
- **BaseView**: SwiftUI view wrapper
- **BaseViewController**: UIKit view controller base

### Design Patterns
- MVVM (Model-View-ViewModel)
- Coordinator Pattern
- Repository Pattern
- Observer Pattern (Combine)
- Protocol-Oriented Programming

## Error Handling

### Error Types
- Network Errors
- Data Persistence Errors
- City Search Errors
- Weather Data Errors
- UserDefaults Errors

### Error Recovery
- Automatic retry for recoverable errors
- User-friendly error messages
- Recovery suggestions
- Error logging and tracking

## Data Flow

### City Search
1. User enters search text
2. Input debounced (500ms)
3. API request made
4. Results displayed/cached
5. Error handled if any

### Weather Details
1. User selects city
2. City added to recent list
3. Weather data fetched
4. Response cached (1 min)
5. UI updated with data

## Dependencies

### Frameworks
- UIKit
- SwiftUI
- Combine
- Foundation
- CoreLocation

### No External Dependencies
Project uses only native iOS frameworks as required.

## Setup & Installation

1. Clone the repository
2. Open BivWeatherAssignment.xcodeproj
3. Create Environment.plist file if not exists
4. Configure your API key in Environment.plist
5. Build and run

### API Key Setup
1. Create or open `Environment.plist` in the project root
2. Add a new entry with key `API_KEY`
3. Set the value to your OpenWeatherMap API key
4. Ensure Environment.plist is added to .gitignore to keep your API key secure

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

### Security Note
- Never commit your API key to version control
- Keep Environment.plist in your .gitignore
- Share API key securely with team members

## Coding Standards

### File Organization
- Clear file/folder structure
- Feature-based modules
- Shared utilities and base classes

### Naming Conventions
- Clear, descriptive names
- Proper use of access control
- Consistent naming patterns

### Documentation
- Header documentation for all types
- Function parameter documentation
- Complex logic explanation
- MARK comments for sections

### Error Handling
- Custom error types
- Comprehensive error messages
- Recovery suggestions
- Proper error propagation

## Testing

### Unit Tests (TODO)
- ViewModel tests
- Service layer tests
- Error handling tests
- Helper/Utility tests

### UI Tests (TODO)
- Critical flow tests
- Error scenario tests
- Accessibility tests

## Future Improvements

### Potential Enhancements
- Offline support
- Location-based weather
- Weather notifications
- Extended forecast
- Weather maps

### Technical Debt
- Comprehensive test coverage
- UI test implementation
- Performance optimization
- Analytics integration

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

This project is for demonstration purposes only.

## Contact

For any questions or feedback, please contact [Your Contact Information]. 