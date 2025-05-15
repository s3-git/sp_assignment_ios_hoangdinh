//
//  SceneDelegate.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/9/25.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // MARK: - Properties

  var window: UIWindow?
  private var coordinator: AppCoordinator?

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

    // Create window
    let window = UIWindow(windowScene: windowScene)
    self.window = window

    // Setup coordinator
    let navigationController = UINavigationController()
    coordinator = AppCoordinator(navigationController: navigationController)

    // Start app
    coordinator?.start()

    // Set root and make visible
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
  }
}
