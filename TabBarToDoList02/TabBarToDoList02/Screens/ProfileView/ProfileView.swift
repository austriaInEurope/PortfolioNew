//
//  ProfileView.swift
//  TabBarToDoList02
//
//  Created by Кристина Игоревна on 13.07.2025.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                PhotoPickerView()
                Text("Email пользователя")
                
                NavigationLink {
                    AccountView()
                } label: {
                    Text("Мой аккаунт")
                        .padding(.bottom, 2)
                        .frame(width: 350, height: 50)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink {
                    SettingsView()
                } label: {
                    Text("Настройки")
                        .padding(.bottom, 2)
                        .frame(width: 350, height: 50)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink {
                    HelpView()
                } label: {
                    Text("Помощь")
                        .padding(.bottom, 2)
                        .frame(width: 350, height: 50)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink {
                    AccountExitView()
                } label: {
                    Text("Выход")
                        .padding(.bottom, 2)
                        .frame(width: 350, height: 50)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
        }
    }
}

#Preview { ProfileView() }
