//
//  View-ExpenseStyle.swift.swift
//  iExpense
//
//  Created by Patrick Battisti Forsthofer on 15/01/22.
//

import SwiftUI

extension View {
    func style(for item: ExpenseItem) -> some View {
        if item.amount < 10 {
            return self.foregroundColor(.green)
        } else if item.amount < 100 {
            return self.foregroundColor(.orange)
        } else {
            return self.foregroundColor(.red)
        }
    }
}
