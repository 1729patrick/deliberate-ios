//
//  ContentView.swift
//  Edutainment
//
//  Created by Patrick Battisti Forsthofer on 09/01/22.
//

import SwiftUI

struct Question: Hashable {
    var title: String
    var question: Int
    var expected: Int
}

struct ContentView: View {
    @State private var animationAmount = 1.0
    
    @State private var selectedTableOf = 0
    @State private var selectedHowManyQuestion = 5
    
    @State private var answers = [String]()
    
    @State private var playing = false
    
    @State private var questions = [Question]()
    
    
    //    let colors: [Color] = [.orange, .red, .gray, .blue,
    //                           .green, .purple, .pink]
    //
    
    
    
    
    var body: some View {
        NavigationView {
            
            ZStack {
                
                if playing == true {
                    Form {
                        ForEach(0..<questions.count) { index in
                            Section(questions[index].title) {
                                TextField(questions[index].title, text: $answers[index])
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                }
                
                if playing == false {
                    Form {
                        Section("Table of") {
                            Picker("Table of", selection: $selectedTableOf) {
                                ForEach(2..<13) {
                                    Text("\($0)")
                                }
                            }
                            .pickerStyle(.segmented)
                            
                        }
                        
                        Section("How many questions") {
                            Picker("How many questions", selection: $selectedHowManyQuestion) {
                                ForEach([5, 10, 15], id: \.self) {
                                    Text("\($0)")
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }
                
                if playing == false {
                    VStack {
                        Spacer()
                        
                        Button(playing == true ? "Done" : "Start", action: didStart )
                            .padding(50)
                            .background(.indigo)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.indigo)
                                    .scaleEffect(animationAmount)
                                    .opacity(2 - animationAmount)
                                    .animation(
                                        .easeInOut(duration: 1)
                                            .repeatForever(autoreverses: false),
                                        value: animationAmount
                                    )
                            )
                            .onAppear {
                                //                        animationAmount = 2
                            }
                    }
                }
            }
            .navigationTitle("Edutainment")
            .toolbar {
                if(playing == true){
                    Button("Done"){
                        didDone()
                    }
                }
            }
            
            
            
        }
        
    }
    
    func didStart(){
        playing = true
        
        questions.removeAll()
        answers.removeAll()
        
        for _ in 0..<selectedHowManyQuestion {
            
            let number = Int.random(in: 2...12)
            let question = Question(
                title: "\(selectedTableOf + 2)x\(number)",
                question: number,
                expected: number * (selectedTableOf + 2)
            )
            
            questions.append(question)
            
            answers.append("")
        }
    }
    
    func didDone(){
        print(questions)
        print(answers)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
