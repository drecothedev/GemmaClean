//
//  ConfettiView.swift
//  Gemma
//
//  Created by Andre jones on 4/6/25.
//

import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<30) { i in
                Circle()
                    .fill(Color.random)
                    .frame(width: 8, height: 8)
                    .offset(y: animate ? CGFloat.random(in: -300...300) : 0)
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
                    .animation(.easeOut(duration: 2).delay(Double(i) * 0.03), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
    }
}


extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

#Preview {
    ConfettiView()
}
