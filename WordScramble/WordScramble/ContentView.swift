//
//  ContentView.swift
//  WordScramble
//
//  Created by Caleb Adepitan on 12/03/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = Array<String>()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    @FocusState private var textFieldIsFocused: Bool

    var body: some View {
        NavigationStack {
            // This can be really useful when using ScrollView with List, which
            // I used at some point. I'm only keeping it for the sake of future
            // references.
            GeometryReader { gp in
                let g = gp.frame(in: .named("viewport"))

                VStack(spacing: 0) {
                    List {
                        Section {
                            TextField("Enter your word", text: $newWord)
                                .textInputAutocapitalization(.never)
                                .focused($textFieldIsFocused)
                        }

                        Section {
                            ForEach(usedWords, id: \.self) { word in
                                HStack {
                                    Image(systemName: "\(word.count).circle")
                                    Text(word)
                                }
                            }
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    ScoreBoard(score: score)
                        .shadow(color: Color.black.opacity(0.1), radius: 7)
                        .safeAreaPadding(.bottom.union(.horizontal))
                }
                .navigationTitle(rootWord)
                .toolbar {
                    Button("Restart", action: startGame)
                }
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage)
                }
            }
        }
        .coordinateSpace(.named("viewport"))
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else { return }

        guard answer.count > 2 else {
            wordError(title: "Word too short", message: "Words must be at least 4 letters long")
            return
        }

        guard !answer.elementsEqual(rootWord) else {
            wordError(title: "Word cannot be same as the root", message: "You cannot provide a word same as '\(rootWord)'")
            return
        }

        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "You've already used this word. Try again!")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make up words at your whim")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
            calculateScore(answer)
        }

        newWord = ""
        textFieldIsFocused = true
    }

    func calculateScore(_ answer: String) {
        score += answer.count
    }

    func startGame() {
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsUrl, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: .newlines)
                rootWord = allWords.randomElement() ?? "silkroad"
                textFieldIsFocused = true
                score = 0
                return
            }
        }

        fatalError("Could not load start.txt from the bundle")
    }

    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    func isReal(word: String) -> Bool {
        let lines = word.components(separatedBy: .newlines)
        let line = lines.randomElement()!
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

        let checker = UITextChecker()
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: trimmed, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
