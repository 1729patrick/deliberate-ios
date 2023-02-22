//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Patrick Battisti Forsthofer on 22/12/21.
//

import SwiftUI

struct FlagImage: View {
    var name: String
    
    var body: some View {
        Image(name)
            .renderingMode(.original)
            .cornerRadius(8)
            .shadow(radius: 5)
    }
}

struct TitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.weight(.semibold))
    }
}

extension View {
    func largeTitle() -> some View {
        modifier(TitleModifier())
    }
}

struct ContentView: View {
    static let allCountries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"]
    
    @State private var countries = allCountries.shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var score = 0
    
    @State private var scoreTitle = ""
    @State private var showingScore = false
    @State private var showingGameOver = false
    
    @State private var level = 1
    @State private var maxLevel = 8
    
    @State private var selectedFlag: Int?
    
    var body: some View {
        ZStack{
            LinearGradient(colors: [Color.indigo, Color.blue, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack{
                Spacer()
                VStack(spacing: 30) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundColor(.white)
                        Text(countries[correctAnswer])
                            .foregroundColor(.white)
                            .largeTitle()
                    }
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(name: countries[number])
                                .rotation3DEffect(.degrees(selectedFlag == number ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                                .opacity(selectedFlag == nil || selectedFlag == number ? 1 : 0.25)
                                .scaleEffect(selectedFlag == nil || selectedFlag == number ? 1 : 0.75)
                                .animation(.easeInOut(duration: 0.5), value: flag)
                        }
                    }
                }
                Spacer()
                VStack {
                    Text("\(level)/\(maxLevel)")
                        .foregroundColor(.white)
                }
            }
        }.alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        }
        .alert("Game over!", isPresented: $showingGameOver) {
            Button("Start Again", action: reset)
        } message: {
            Text("Your final score was \(score).")
        }
    }
    
    func flagTapped(_ number: Int) {
        selectedFlag = number
        
        if(number == correctAnswer) {
            scoreTitle = "Correct"
            score += 1
        }else {
            scoreTitle = "Wrong! That’s the flag of \(countries[number])"
        }
        
        if level == maxLevel {
            showingGameOver = true
        } else {
            showingScore = true
        }
    }
    
    func askQuestion() {
        countries.remove(at: correctAnswer)
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        level += 1
        
        selectedFlag = nil
    }
    
    func reset() {
        score = 0
        level = 0
        countries = Self.allCountries
        askQuestion()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
