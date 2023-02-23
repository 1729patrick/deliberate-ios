//
//  DataModel.swift
//  Designs4u
//
//  Created by Patrick Battisti Forsthofer on 23/02/23.
//

import SwiftUI

@MainActor
class DataModel: ObservableObject {
    @Published var people = [Person]()
    
    @Published var searchText = ""
    @Published var tokens = [Skill]()
    private var allSkills = [Skill]()
    
    @Published private(set) var selected = [Person]()
    
    var searchResults: [Person] {
        let setTokens = Set(tokens)

        return people.filter { person in
            guard selected.contains(person) == false else { return false }
            guard person.skills.isSuperset(of: setTokens) else { return false }
            guard searchText.isEmpty == false else { return true }
            
            for string in [person.firstName, person.lastName, person.bio, person.details] {
                if string.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
            }

            return false
        }
    }
    
    var suggestedTokens: Binding<[Skill]> {
        if searchText.starts(with: "#") {
            return .constant(allSkills)
        } else {
            return .constant([])
        }
    }

    func fetch() async throws {
        let url = URL(string: "https://www.hws.dev/designers.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        people = try JSONDecoder().decode([Person].self, from: data)
        allSkills = Set(people.map(\.skills).joined()).sorted()
    }
    
    func select(_ person: Person) {
        selected.append(person)
    }

    func remove(_ person: Person) {
        if let index = selected.firstIndex(of: person) {
            selected.remove(at: index)
        }
    }
    
}
