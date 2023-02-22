//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Patrick Battisti Forsthofer on 28/12/21.
//

import SwiftUI

struct ContentView: View {
    @State var moves = ["🪨", "📄", "✂️"].shuffled()
    @State var appChoise = Int.random(in: 0..<3)
    @State var showingResult = false
    @State var resultTitle = ""
    
    @State var score = 0
    
    var body: some View {
        ZStack{
            LinearGradient(colors: [.indigo, .blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack{
                Text("Rock, Paper and Scissor")
                    .padding()
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                
                HStack{
                    ForEach(moves, id:\.self){ move in
                        Spacer()
                        Button(move){
                            didAnswer(move)
                        }
                        .font(.system(size: 100))
                        Spacer()
                    }
                }
                
                Text("Score: \(score)")
                    .padding()
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
            }.alert(resultTitle, isPresented: $showingResult){
                Button("Let's go", action: didContinue)
            }
        }.ignoresSafeArea()
    }
    
    func didAnswer(_ userMove: String){
        let appMove = moves[appChoise]
        
        if userMove == "🪨" && appMove == "✂️" ||
            userMove == "✂️" && appMove == "📄" ||
            userMove == "📄" &&  appMove == "🪨" {
            
            resultTitle = "You Win!! App chose \(appMove)"
            score += 1
        } else if userMove == appMove {
            resultTitle = "Tie!! App also chose \(appMove)"
        }else {
            resultTitle = "You Lose!! App chose \(appMove)"
            
            if score > 0 {
                score -= 1
            }
        }
        
        showingResult = true
    }
    
    func didContinue(){
        appChoise = Int.random(in: 0..<3)
        withAnimation {
            moves.shuffle()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
