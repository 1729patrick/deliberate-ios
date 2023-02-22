//
//  Activities.swift
//  HabitTracking
//
//  Created by Patrick Battisti Forsthofer on 25/01/22.
//

import Foundation

class Activities: ObservableObject {
    @Published var items: [Activity] = [Activity]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                print(encoded)
                
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
  
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([Activity].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = []
    }
    
}
