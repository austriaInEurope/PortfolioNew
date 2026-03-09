//
//  HelpView.swift
//  TabBarToDoList02
//
//  Created by Кристина Игоревна on 06.07.2025.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 3)
                    )
                
                Text("Помощь")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                
                VStack(alignment: .leading, spacing: 10) {
                    HelpRow(icon: "1.circle", text: "Выберите нужную задачу в списке")
                    HelpRow(icon: "2.circle", text: "Нажмите для редактирования")
                    HelpRow(icon: "3.circle", text: "Используйте кнопки управления")
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
}



#Preview {
    HelpView()
}
