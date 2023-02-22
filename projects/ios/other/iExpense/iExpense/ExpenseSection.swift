//
//  ExpenseSection.swift
//  iExpense
//
//  Created by Patrick Battisti Forsthofer on 15/01/22.
//

import SwiftUI

struct ExpenseSection: View {
    let title: String
    let expenses: [ExpenseItem]
    let deleteItems: (IndexSet) -> Void
    
    var body: some View {
        if expenses.count > 0 {
            Section(title) {
                ForEach(expenses) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        
                        Spacer()
                        
                        Text(item.amount, format: .localCurrency)
                            .style(for: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
    }
}

struct ExpenseSection_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseSection(title: "", expenses: [], deleteItems: { _ in })
    }
}
