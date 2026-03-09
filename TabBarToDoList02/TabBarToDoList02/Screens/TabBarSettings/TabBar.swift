//
//  TabBar.swift
//  TabBarToDoList02
//
//  Created by Кристина Игоревна on 06.07.2025.
//

import Foundation
import SwiftUI

struct MainTabBar: View {
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("главный экран", systemImage: "heart")
                }
            
            SettingsView()
                .tabItem {
                    Label("настройки", systemImage: "house")
                }
            
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person")
                }
        }
        .frame(maxWidth: .infinity)
    }
}
 
#Preview { MainTabBar() }
