# Shared Components and Utilities

This directory contains shared components, utilities, and base classes used throughout the Weather App.

## Directory Structure

```
Shared/
├── Base/           # Base classes and protocols
├── Components/     # Reusable UI components
├── Constants/      # App-wide constants
├── Extensions/     # Swift extensions
├── Network/        # Network layer
├── Storage/        # Storage and caching
└── Utilities/      # Utility managers
```

## Base

### Base Classes
- `BaseViewModel`: Generic base class for view models with state management
  - State management with Combine
  - Error handling
  - Loading state
  - Memory-safe cancellable management
  - Logger integration

### Protocols
- `BaseViewModelType`: Protocol defining view model requirements
  - Generic state type
  - State publisher
  - Error handling
  - Binding setup

## Components

### UI Components
- `CustomNavigationBar`: Flexible navigation bar with title and buttons
- `CustomTabBar`: Animated tab bar with selection handling
- `SearchBarView`: Reusable search bar with clear and cancel buttons
- `WeatherCard`: Weather information display card
- `EmptyStateView`: View for displaying empty states
- `LoadingView`: Loading indicator with message
- `ErrorView`: Error display with retry button
- `RefreshableView`: Pull-to-refresh functionality

## Constants

### AppConstants
- `API`: API configuration and endpoints
  - Base URL
  - Timeout intervals
  - Cache sizes
- `Cache`: Caching configuration
  - Expiration intervals
  - Storage keys
  - History limits
- `UI`: UI constants
  - Corner radius
  - Padding
  - Animation durations
  - Debounce intervals
- `Weather`: Weather-specific settings
  - Default units
  - Language
  - Refresh intervals
- `Validation`: Input validation rules
  - Search length limits
- `ErrorMessages`: User-facing error messages
- `Keys`: Configuration keys

### Environment
- API key management
- Configuration access
- Environment-specific settings

## Utilities

### Managers
- `NetworkReachabilityManager`: Monitors network connectivity
- `KeyboardManager`: Handles keyboard events and visibility
- `PermissionsManager`: Manages app permissions
- `AnalyticsManager`: Tracks app events and user properties
- `ThemeManager`: Manages app theming and appearance
- `Logger`: Comprehensive logging system

## Extensions

### SwiftUI Extensions
- View modifiers for common styling
- Color extensions for system colors
- Loading and error state modifiers

### Combine Extensions
- Publisher extensions for memory safety
- Async/await support
- Cancellable management

## Network Layer
- `NetworkManager`: Handles API requests
- Response caching
- Error handling
- Request/response logging

## Storage
- `CacheManager`: Manages response caching
- UserDefaults extensions
- File system utilities

## Usage

### Base Classes
1. Inherit from `BaseViewModel<YourState>`
2. Implement required state type
3. Override `setupBindings()`
4. Use provided error handling

### Constants
1. Use `AppConstants` for app-wide values
2. Use `Environment` for configuration
3. Keep constants organized by category
4. Document constant purposes

### Components
1. Use provided UI components
2. Follow design system
3. Maintain consistency
4. Add preview providers

### Utilities
1. Use singleton instances
2. Follow memory safety guidelines
3. Implement proper error handling
4. Add comprehensive logging

## Best Practices

### Base Classes
- Use generic state types
- Implement proper error handling
- Maintain memory safety
- Add comprehensive documentation

### Constants
- Use meaningful names
- Group related constants
- Document constant values
- Use type-safe constants

### Components
- Follow SwiftUI best practices
- Maintain accessibility
- Support dark mode
- Add preview providers

### Utilities
- Implement proper error handling
- Use appropriate patterns
- Maintain data consistency
- Handle edge cases

## Testing

### Base Classes
- Unit tests for state management
- Error handling tests
- Memory management tests
- Integration tests

### Components
- UI tests for components
- Accessibility tests
- Dark mode tests
- Performance tests

### Utilities
- Unit tests for managers
- Integration tests
- Performance tests
- Edge case tests

## Contributing
1. Follow existing code style
2. Add documentation
3. Include tests
4. Update this README if needed

## License
This project is licensed under the MIT License. 