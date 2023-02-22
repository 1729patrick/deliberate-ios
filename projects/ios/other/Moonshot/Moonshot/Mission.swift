//
//  Mission.swift
//  Moonshot
//
//  Created by Patrick Battisti Forsthofer on 15/01/22.
//

import Foundation

struct Mission: Codable, Identifiable {
    struct CrewRole: Codable {
        let name: String
        let role: String
    }

    let id: Int
    let launchDate: Date?
    let crew: [CrewRole]
    let description: String
    
    var displayName: String {
        "Apollo \(id)"
    }

    var image: String {
        "apollo\(id)"
    }
    
    func formatLaunchDate(date: Date.FormatStyle.DateStyle? = .abbreviated) -> String {
        launchDate?.formatted(date: date!, time: .omitted) ?? "N/A"
    }
}
