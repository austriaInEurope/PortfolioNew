//
//  HomeView.swift
//  TabBarToDoList02
//
//  Created by Кристина Игоревна on 13.07.2025.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage("isDark") private var isDarkMode: Bool = false
    var body: some View {
        
        VStack {
            Toggle("Your light/dark Mode: ", isOn: $isDarkMode)
                .foregroundColor(.gray)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 15)
    }
}
#Preview {
    SettingsView()
}
