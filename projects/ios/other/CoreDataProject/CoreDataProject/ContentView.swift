//
//  ContentView.swift
//  CoreDataProject
//
//  Created by Patrick Battisti Forsthofer on 02/02/22.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc
    @State private var sortDescriptors: [SortDescriptor<Country>] = [SortDescriptor(\.name)]
    
    
    var body: some View {
        VStack {
            FilteredList(
                filterKey: "name",
                filterValue: " ",
                predicate: .beginsWith,
                sortDescriptors: sortDescriptors
            ) {
                (country: Country) in
                Text(country.name ?? "Unknow")
            }
            
            Button("Hello, world!"){
                var country1 = Country(context: moc)
                country1.name = " USA"
                
                var country2 = Country(context: moc)
                country2.name = " UK"
                
                var country3 = Country(context: moc)
                country3.name = " PT"
                
                var country4 = Country(context: moc)
                country4.name = " BR"
                
                try? moc.save()
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
