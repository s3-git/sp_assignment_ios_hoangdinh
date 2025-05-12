//
//  SceneDelegate.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/9/25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // MARK: - Properties

  var window: UIWindow?

  // MARK: - Initialization

  override init() {
    super.init()
  }

  // MARK: - UIWindowSceneDelegate

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    // Create window with windowScene
    let window = UIWindow(windowScene: windowScene)

    // Create navigation controller with HomeViewController as  root
    let homeController = HomeViewController(viewModel: HomeViewModel())
    let navigationController = UINavigationController(rootViewController: homeController)

    // Configure navigation bar appearance
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .systemBackground
    navigationController.navigationBar.standardAppearance = appearance
    navigationController.navigationBar.scrollEdgeAppearance = appearance

    // Set root view controller
    window.rootViewController = navigationController
    window.makeKeyAndVisible()

    self.window = window
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Reset dependency container when scene disconnects
    // This is useful for testing or when you want to reset the app state
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }

}
