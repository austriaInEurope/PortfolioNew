//
//  Button.swift
//  ToDoListCreated2
//
//  Created by Кристина Игоревна on 22.06.2025.
//

import Foundation

import SwiftUI

struct ButtonPlus: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.bottom, 2)
            .frame(width: 35, height: 35)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(17.5)
    }
}


