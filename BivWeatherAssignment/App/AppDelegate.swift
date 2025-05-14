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

    // MARK: - Public Methods
    func configureAppAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ThemeManager.shared.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: ThemeManager.shared.textColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: ThemeManager.shared.textColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = ThemeManager.shared.accentColor

        // Configure search bar appearance
        let searchBarAppearance = UISearchBar.appearance()
        searchBarAppearance.tintColor = ThemeManager.shared.accentColor
        searchBarAppearance.barTintColor = ThemeManager.shared.backgroundColor

        // Configure table view appearance
        UITableView.appearance().backgroundColor = ThemeManager.shared.backgroundColor
        UITableViewCell.appearance().backgroundColor = ThemeManager.shared.backgroundColor

        // Configure label appearance
        UILabel.appearance().textColor = ThemeManager.shared.textColor
    }
}
