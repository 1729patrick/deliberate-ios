//
//  ContentView.swift
//  Concurrency
//
//  Created by Patrick Battisti Forsthofer on 20/02/23.
//

import SwiftUI

extension URLSession {
    func decode<T: Decodable>(
        _ type: T.Type = T.self,
        from url: URL,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws -> T {
        let (data, _) = try await data(from: url)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy

        let decoded = try decoder.decode(T.self, from: data)
        return decoded
    }
}

struct Petition: Decodable, Identifiable {
    let id: String
    let title: String
    let body: String
    let signatureCount: Int
    let signatureThreshold: Int
}

struct PetitionView: View {
    let petition: Petition

    var body: some View {
        ScrollView {
            Text(petition.title)
                .font(.title)
                .padding(.horizontal)

            Text(petition.body)
                .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContentView: View {
    @State private var petitions = [Petition]()

    var body: some View {
        NavigationView {
            List(petitions) { petition in
                NavigationLink(destination: PetitionView(petition: petition)) {
                    VStack(alignment: .leading) {
                        Text(petition.title)

                        HStack {
                            Spacer()
                            Text("\(petition.signatureCount)/\(petition.signatureThreshold)")
                                .font(.caption)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Petitions")
            .task {
                do {
                    let url = URL(string: "https://hws.dev/petitions.json")!
                    let (data, _) = try await URLSession.shared.data(from: url)
                    petitions = try JSONDecoder().decode([Petition].self, from: data)
                } catch {
                    print("Failed to fetch petitions.")
                }
            }
        }
    }
}
