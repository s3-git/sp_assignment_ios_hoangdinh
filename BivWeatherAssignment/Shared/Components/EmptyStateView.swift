//
//  EmptyStateView 2.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/14/25.
//

import SwiftUI

// MARK: - Empty State View
struct EmptyStateView: View {
    // MARK: - Properties
    let title: String
    let message: String
    let systemImage: String
    let action: (() -> Void)?
    let actionTitle: String?
    
    // MARK: - Initialization
    init(
        title: String,
        message: String,
        systemImage: String = "exclamationmark.triangle",
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.action = action
        self.actionTitle = actionTitle
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: AppConstants.UserInterface.padding) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundStyle(ThemeManager.Color.textColor.toColor)
            
            Text(title)
                .font(Font(ThemeManager.Fonts.headline))
                .multilineTextAlignment(.center)
                .foregroundStyle(ThemeManager.Color.textColor.toColor)
            
            Text(message)
                .font(Font(ThemeManager.Fonts.body))
                .foregroundStyle(ThemeManager.Color.textColor.toColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Font(ThemeManager.Fonts.headline))
                        .foregroundColor(.white)
                        .padding(.horizontal, AppConstants.UserInterface.padding * 1.5)
                        .padding(.vertical, AppConstants.UserInterface.padding * 0.75)
                        .background(ThemeManager.Color.accentColor.toColor)
                        .cornerRadius(AppConstants.UserInterface.cornerRadius * 0.5)
                }
                .padding(.top, AppConstants.UserInterface.padding * 0.5)
            }
        }
        .padding(AppConstants.UserInterface.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
