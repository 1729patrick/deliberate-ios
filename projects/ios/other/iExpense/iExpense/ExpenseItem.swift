//
//  ExpenseItem.swift
//  iExpense
//
//  Created by Patrick Battisti Forsthofer on 12/01/22.
//

import Foundation


struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    
    let name: String
    let type: String
    let amount: Double
    
}
