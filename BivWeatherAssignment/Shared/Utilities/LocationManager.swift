import Foundation
import CoreLocation
import Combine

/// Location manager for handling location services
class LocationManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var error: Error?

    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private var locationSubject = PassthroughSubject<CLLocation, Error>()

    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
    }

    // MARK: - Private Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000 // Update every 1km
    }

    // MARK: - Public Methods
    /// Request location authorization
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Start updating location
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    /// Stop updating location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    /// Get current location as a publisher
    func getCurrentLocation() -> AnyPublisher<CLLocation, Error> {
        if let location = currentLocation {
            return Just(location)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return locationSubject
            .first()
            .eraseToAnyPublisher()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            error = NSError(
                domain: "LocationManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Location access denied"]
            )
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationSubject.send(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
        locationSubject.send(completion: .failure(error))
    }
}
