//
//  ContentView.swift
//  WordScramble
//
//  Created by Larry Nguyen on 9/9/20.
//  Copyright © 2020 Larry Nguyen. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var totalLetters = 0
    
    var body: some View {
        
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Section {
                    Text("Total words = \(usedWords.count)")
                    Text("Total letters = \(totalLetters)")
                }
                
            }
            .navigationBarItems(trailing:
                Button(action: {
                    self.startGame()
                }) {
                    Text("New word")
                }
            )
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2 else {
            wordError(title: "Word too short", message: "Words must be at least 3 letters long")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Invalid word", message: "Nice try")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Try another word")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word includes invalid letters", message: "Must use letters from the word above")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Not a real word", message: "Please try another word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        totalLetters += answer.count
        newWord = ""
    }
    
    func startGame() {
        // Reset score and used words
        usedWords = [String]()
        totalLetters = 0
        
        // Find URL for start.txt
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // split string on line breaks into array of strings
                let allWords = startWords.components(separatedBy: "\n")
                // select random word
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    // Check if word has been used already
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // Check if word can be made out of random word
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
    
    // Check if word is valid
    func isReal(word: String) -> Bool {
        if word.count < 3 {
            return false
        } else {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
            return misspelledRange.location == NSNotFound
        }
    }
    
    // Show error
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
