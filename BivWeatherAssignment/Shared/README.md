# Shared Components and Utilities

This directory contains shared components, utilities, and base classes used throughout the Weather App. These components are designed to be reusable, maintainable, and follow SOLID principles.

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
- `BaseViewModel`: Thread-safe generic base class for view models
  - Combine-based state management
  - Comprehensive error handling with recovery options
  - Loading state with timeout handling
  - Automatic memory management for cancellables
  - Integrated logging system with different levels
  - Support for analytics tracking
  - Weak self handling to prevent retain cycles

### Protocols
- `BaseViewModelType`: Protocol defining view model contract
  - Generic associated state type
  - Thread-safe state publisher
  - Standardized error handling interface
  - Memory-safe binding setup
  - Lifecycle management

## Components

### UI Components
- `CustomNavigationBar`: 
  - Dynamic navigation bar with customizable appearance
  - Support for large titles
  - Accessibility support
  - Dark mode compatible
- `CustomTabBar`: 
  - Smooth animations with customizable timing
  - Badge support
  - Haptic feedback
  - Custom selection indicators
- `SearchBarView`: 
  - Real-time search with debouncing
  - Voice input support
  - Search history integration
  - Customizable appearance
- `WeatherCard`: 
  - Animated weather transitions
  - Dynamic backgrounds
  - Support for different weather conditions
  - Accessibility labels
- `EmptyStateView`: 
  - Customizable illustrations
  - Action button support
  - Dynamic messaging
- `LoadingView`: 
  - Multiple animation styles
  - Progress indication
  - Cancellable operations
- `ErrorView`: 
  - Multiple error states
  - Retry functionality
  - Custom error messaging
- `RefreshableView`: 
  - Custom refresh animations
  - Progress tracking
  - Completion handling

## Constants

### AppConstants
- `API`: 
  - Environment-based configuration
  - Timeout management
  - Retry policies
  - Cache configuration
- `Cache`: 
  - Tiered caching strategy
  - Memory and disk cache limits
  - Expiration policies
- `UI`: 
  - Design system constants
  - Dynamic typography
  - Spacing system
  - Animation curves
- `Weather`: 
  - Unit conversion
  - Update frequencies
  - Display formats
- `Validation`: 
  - Input constraints
  - Format rules
- `ErrorMessages`: 
  - Localized error messages
  - Recovery suggestions
- `Keys`: 
  - Secure key management
  - Environment variables

### Environment
- Secure API key handling
- Environment-specific settings
- Debug vs Release configuration

## Network Layer
- `NetworkManager`: 
  - Protocol-based API client
  - Response validation
  - Automatic retry
  - Request/Response logging
  - Certificate pinning
  - Comprehensive error mapping

## Storage
- `CacheManager`: 
  - Multi-level caching
  - Encryption support
  - Automatic cleanup
  - Migration handling

## Best Practices

### Memory Management
- Proper use of weak references
- Cancellable management
- Resource cleanup
- Retain cycle prevention

### Error Handling
- Comprehensive error types
- Recovery strategies
- User-friendly messages
- Logging and analytics

### Testing
- Unit test coverage
- UI test automation
- Performance testing
- Memory leak detection

## Security

### Data Protection
- Secure storage
- API key protection
- Network security
- Input validation

## Contributing
1. Follow Swift style guide
2. Add comprehensive documentation
3. Include unit tests
4. Update README
5. Create detailed PR description

## Version Control
- Feature branching
- Semantic versioning
- Clean commit history
- Code review process

## License
This project is licensed under the MIT License. 