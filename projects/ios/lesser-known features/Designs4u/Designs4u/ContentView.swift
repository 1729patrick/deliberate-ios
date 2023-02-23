//
//  ContentView.swift
//  Designs4u
//
//  Created by Patrick Battisti Forsthofer on 23/02/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = DataModel()
    @State private var selectedDesigner: Person?
    @Namespace var namespace
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(model.searchResults) { person in
                        ForEach(model.searchResults) { person in
                            DesignerRow(person: person, model: model, namespace: namespace, selectedDesigner: $selectedDesigner)
                        }
                    }   
                }
                .padding(.horizontal)
            }
            .navigationTitle("Design4u")
            .searchable(text: $model.searchText, tokens: $model.tokens, suggestedTokens: model.suggestedTokens, prompt: Text("Search, or use # to select skills")) { token in
                Text(token.id)
            }
            .sheet(item: $selectedDesigner, content: DesignerDetails.init)
            .safeAreaInset(edge: .bottom) {
                if model.selected.isEmpty == false {
                    VStack {
                        HStack(spacing: -10) {
                            ForEach(model.selected) { person in
                                Button {
                                    withAnimation(.spring()) {
                                        model.remove(person)
                                    }
                                } label: {
                                    AsyncImage(url: person.thumbnail, scale: 3)
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.white, lineWidth: 2)
                                        )
                                        .matchedGeometryEffect(id: person.id, in: namespace)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        NavigationLink {
                            // go to the next screen
                        } label: {
                            Text("Select ^[\(model.selected.count) Person](inflect: true)")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .contentTransition(.identity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.horizontal, .top])
                    .background(.ultraThinMaterial)
                }
            }
        }
        .task {
            do {
                try await model.fetch()
            } catch {
                print("Error handling is great!")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
