
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
 <img src="https://github.com/user-attachments/assets/95a99ff3-289b-4b09-916a-44c000b07eea" width="200">
 <img src="https://github.com/user-attachments/assets/762b0cd1-77de-4893-8475-9df04f811082" width="200">
 <img src="https://github.com/user-attachments/assets/972ea542-2ff8-40b4-a741-e6bde2b69d8b" width="200">
 <img src="https://github.com/user-attachments/assets/d27003b9-72b0-4d60-b267-2c1ac2017ef2" width="200">
 <img src="https://github.com/user-attachments/assets/c0d3f4e8-6da0-47bd-a7ba-0b0883324791" width="200">
</p>

### City Screen
<p align="center">
 <img src="https://github.com/user-attachments/assets/33894eef-ee51-4c14-998c-ce0598b25f71" width="200">
</p>

## Test Coverage
### Test Result
<p align="center">
 <img src="https://github.com/user-attachments/assets/a292c4c8-72c0-410d-b441-ed5ccc27694d" width="600">
</p>

### Coverage
<p align="center">
 <img src="https://github.com/user-attachments/assets/45bc0ddf-f724-4a89-86e5-6cb620e861aa" width="600">
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
