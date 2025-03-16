//
//  ScoreBoard.swift
//  WordScramble
//
//  Created by Caleb Adepitan on 15/03/2025.
//

import SwiftUI

struct ScoreBoard: View {
    
    let score: Int
    let height: CGFloat = 64
    
    var body: some View {
            ZStack {
                RadialGradient(colors: [.blue.opacity(0.35), .white], center: .bottom, startRadius: 10, endRadius: 400)
                    .clipShape(.rect(cornerRadius: 40))

                HStack(alignment: .center) {
                    Text("Score")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(score)")
                        .font(.system(size: 32, weight: .bold))
                }
                .padding(.all, 24)
            }
            .frame(height: height)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 40))
            .overlay {
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .strokeBorder(.gray.opacity(0.13), lineWidth: 1)
            }
    }
}
