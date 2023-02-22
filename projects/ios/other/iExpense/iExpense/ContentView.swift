//
//  ContentView.swift
//  iExpense
//
//  Created by Patrick Battisti Forsthofer on 10/01/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
  
    
    var body: some View {
        NavigationView {
            List {
                    ExpenseSection(title: "Business", expenses: expenses.bussinessItems, deleteItems: removeBusinessItems)
                    ExpenseSection(title: "Personal", expenses: expenses.personalItems, deleteItems: removePersonalItems)
                
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
        
        
    }
    
    func removePersonalItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
    
    func removeBusinessItems(at offsets: IndexSet){
        let fixedOffsets: IndexSet = IndexSet(offsets.map({$0 + expenses.personalItems.count}))
        
        expenses.items.remove(atOffsets: fixedOffsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
