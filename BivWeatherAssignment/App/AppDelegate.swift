//
//  AppDelegate.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/9/25.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAppAppearance()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Private Methods
    private func configureAppAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ThemeManager.shared.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: ThemeManager.shared.textColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: ThemeManager.shared.textColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = ThemeManager.shared.accent

        // Configure search bar appearance
        let searchBarAppearance = UISearchBar.appearance()
        searchBarAppearance.tintColor = ThemeManager.shared.accent
        searchBarAppearance.barTintColor = ThemeManager.shared.backgroundColor

        // Configure table view appearance
        UITableView.appearance().backgroundColor = ThemeManager.shared.backgroundColor
        UITableViewCell.appearance().backgroundColor = ThemeManager.shared.backgroundColor

        // Configure label appearance
        UILabel.appearance().textColor = ThemeManager.shared.textColor
    }
}
