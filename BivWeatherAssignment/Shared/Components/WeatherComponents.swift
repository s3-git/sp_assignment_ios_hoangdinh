import SwiftUI

// MARK: - Weather Card
struct WeatherCard: View {
    let temperature: String
    let description: String
    let humidity: String
    let iconURL: URL?
    
    var body: some View {
        VStack(spacing: 16) {
            if let iconURL = iconURL {
                AsyncImage(url: iconURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
            }
            
            Text(temperature)
                .font(.system(size: 48, weight: .bold))
            
            Text(description)
                .font(.title2)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "humidity")
                Text(humidity)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Text("Retry")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview Provider
struct WeatherComponents_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeatherCard(
                temperature: "23°C",
                description: "Sunny",
                humidity: "65%",
                iconURL: nil
            )
            .previewLayout(.sizeThatFits)
            
            EmptyStateView(
                title: "No Cities",
                message: "Search for a city to see its weather",
                systemImage: "magnifyingglass"
            )
            .previewLayout(.sizeThatFits)
            
            LoadingView(message: "Loading weather data...")
                .previewLayout(.sizeThatFits)
            
            ErrorView(
                error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load weather data"]),
                retryAction: {}
            )
            .previewLayout(.sizeThatFits)
        }
    }
} 
