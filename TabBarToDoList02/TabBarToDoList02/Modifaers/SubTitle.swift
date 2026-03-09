
//
//  SubTitle.swift
//  ToDoListCreated2
//
//  Created by Кристина Игоревна on 22.06.2025.
//

import Foundation

import SwiftUI


struct SubTitle: ViewModifier {
    var size: CGFloat = 19
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size))
            .frame(maxWidth: .infinity, maxHeight: 47 )
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .foregroundColor(.gray.opacity(0.8))
            .padding(.bottom, 10)
    }
}
