//
//  LoadingView.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/14/25.
//
import SwiftUI

// MARK: - Loading View
struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: AppConstants.UserInterface.padding) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(ThemeManager.shared.accentColor.toColor)

            Text(message)
                .font(Font(ThemeManager.Fonts.body))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)
        }
        .padding(AppConstants.UserInterface.padding)
        .background(ThemeManager.shared.backgroundColor.toColor)
        .cornerRadius(AppConstants.UserInterface.cornerRadius)
        .shadow(
            color: ThemeManager.shared.shadowColor.toColor.opacity(0.1),
            radius: AppConstants.UserInterface.padding * 0.625,
            x: 0,
            y: AppConstants.UserInterface.padding * 0.3125
        )
    }
}
