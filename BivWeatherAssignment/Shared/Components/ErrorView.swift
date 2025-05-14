//
//  ErrorView.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/14/25.
//

import SwiftUI

// MARK: - Error View
struct ErrorView: View {
    let error: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: AppConstants.UserInterface.padding) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(ThemeManager.shared.errorColor.toColor)

            Text(error)
                .font(Font(ThemeManager.Fonts.body))
                .foregroundStyle(ThemeManager.shared.textColor.toColor)
                .multilineTextAlignment(.center)

            Button(action: retryAction) {
                Text("Retry")
                    .font(Font(ThemeManager.Fonts.headline))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppConstants.UserInterface.padding * 2)
                    .padding(.vertical, AppConstants.UserInterface.padding * 0.75)
                    .background(ThemeManager.shared.accentColor.toColor)
                    .cornerRadius(AppConstants.UserInterface.cornerRadius * 0.5)
            }
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
