//
//  Activity.swift
//  HabitTracking
//
//  Created by Patrick Battisti Forsthofer on 25/01/22.
//

import Foundation

struct Activity: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var description: String
    
    var completed: Double = 0.0
}
