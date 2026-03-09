//
//  TabBarToDoList02App.swift
//  TabBarToDoList02
//
//  Created by Кристина Игоревна on 06.07.2025.
//

import SwiftUI

@main
struct TabBarToDoList02App: App {
    var body: some Scene {
        WindowGroup {
            MainTabBar()
                .modelContainer(for: Task.self)
        }
    }
}
