
A modern iOS weather application that allows users to search for cities and view their weather information. Built with a focus on MVVM architecture, maintainability, and performance.

## Use Cases
### Use Case 1
- As a user
- Given I am on the home screen
- When I type in to the search bar on the home page
- Then i will see a list of available cities that pattern matches what I have typed

### Use Case 2
- As a user
- Given I am on the home screen
- And there is a list of available cities (based on what I've typed) When I tap on a city
- Then I will be on the city Screen
- Then I will see the current weather image
- Then I will see the current humidity
- Then I will see the current weather in text form
- Then I will see the current weather temperature

### Use Case 3
- As a user
- Given I am on the home screen
- And I have not viewed a City's weather Then I should see a list view empty state

### Use Case 4
- As a user
- Given I am on the home screen
- And I have previously viewed any city's weather
- Then I should see an ordered list of the recent 10 cities that I have previously seen. And I should see the latest City that I have viewed at the top of the list

### Use Case 5
- As a user
- Given I have previously viewed any city's weather
- When I have relaunched the app (terminating the app and relaunched)
- Then I should see a ordered list of the recent 10 cities that I have previously seen.
- The reviewers will be looking out on whether you adhere to clean code practices and readability.

## Interface
### Search Screen
<p align="center">

</p>

### City Screen
<p align="center">

</p>

## Test Coverage
### Test Result
<p align="center">


</p>

### Coverage
<p align="center">

</p>

## Architecture

### Design Patterns
- MVVM 
- Coordinator for navigation
- Repository for data access
- Observer using Combine
- Protocol-oriented design
- Dependency injection

## Dependencies

### Native Frameworks
- UIKit (UI components)
- SwiftUI (Modern views)
- Combine (Reactive programming)
- Foundation (Core utilities)

### Zero External Dependencies
- Custom networking layer
- Built-in caching system
- Native reactive programming

## Setup & Installation

1. Clone the repository
2. Open BivWeatherAssignment.xcodeproj
3. Configure Environment.swift
4. Add API key securely
5. Build and run

## License

This project is licensed under the MIT License.


For questions or feedback, please contact the development team. 
