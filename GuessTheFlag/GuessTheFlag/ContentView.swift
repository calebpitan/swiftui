//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Caleb Adepitan on 21/06/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showingAlert = false
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0

    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()

    @State private var correctAnswer: Int = .random(in: 0 ... 2)
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 700).ignoresSafeArea()

            VStack {
                Spacer()
                Text("Guess The Flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                VStack(spacing: 30) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }

                    ForEach(0 ..< 3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            Image(countries[number]).clipShape(.capsule).shadow(radius: 5)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))

                Spacer()
                Spacer()
                Text("Score: \(score)")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(score)")
        }
    }

    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            score += 10
            scoreTitle = "Correct!"
        } else {
            score = max(0, score - 5)
            scoreTitle = "Wrong! That's the flag of \(countries[number])"
        }
        showingScore = true
    }

    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0 ... 2)
    }
}

#Preview {
    ContentView()
}
