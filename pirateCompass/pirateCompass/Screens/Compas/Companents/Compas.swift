//
//  Compas.swift
//  pirateCompass
//
//  Created by Кристина Игоревна on 20.04.2025.
//

import SwiftUI

struct Compas: View {
    @Binding var angle: Double
    var body: some View {
        
        HStack() {
            Text("East")
                .padding(.trailing, 30)
                .foregroundColor(.blue)
            
            VStack(){
                Text("Nord")
                    .padding(.bottom, 30)
                    .foregroundColor(.blue)
                
                ZStack(alignment: .center) {
                    Circle()
                        .stroke(Color .black, lineWidth: 17)
                    Arrow()
                        .rotationEffect(.degrees(angle))
                }
                Text("South")
                    .padding(.top, 30)
                    .foregroundColor(.blue)
            }
            Text("Weast")
                .padding(.leading, 30)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: 500, maxHeight: 500)
    }
}

#Preview {
    Compas(angle: .constant(0))
}
