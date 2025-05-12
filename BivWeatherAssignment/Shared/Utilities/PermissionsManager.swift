import Foundation
import UIKit
import CoreLocation
import UserNotifications
import Combine

/// Manager for handling app permissions
class PermissionsManager: NSObject {
    // MARK: - Published Properties
    @Published var locationPermission: CLAuthorizationStatus = .notDetermined
    @Published var notificationPermission: UNAuthorizationStatus = .notDetermined

    // MARK: - Properties
    static let shared = PermissionsManager()
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private override init() {
        super.init()
        setupLocationManager()
        checkNotificationPermission()
    }

    // MARK: - Private Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationPermission = locationManager.authorizationStatus
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermission = settings.authorizationStatus
            }
        }
    }

    // MARK: - Public Methods
    /// Request location permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Request notification permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self?.notificationPermission = .authorized
                } else {
                    self?.notificationPermission = .denied
                }
            }
        }
    }

    /// Check if location permission is granted
    var isLocationPermissionGranted: Bool {
        locationPermission == .authorizedWhenInUse || locationPermission == .authorizedAlways
    }

    /// Check if notification permission is granted
    var isNotificationPermissionGranted: Bool {
        notificationPermission == .authorized
    }

    /// Open app settings
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension PermissionsManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationPermission = manager.authorizationStatus
    }
}
