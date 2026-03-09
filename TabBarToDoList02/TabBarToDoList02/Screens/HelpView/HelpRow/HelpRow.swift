//
//  HelpRow.swift
//  TabBarToDoList02
//
//  Created by Кристина Игоревна on 22.06.2025.
//

import SwiftUI


struct HelpRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

