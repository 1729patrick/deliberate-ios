//
//  FilteredList.swift
//  CoreDataProject
//
//  Created by Patrick Battisti Forsthofer on 03/02/22.
//

import CoreData
import SwiftUI

struct FilteredList<T: NSManagedObject, Content: View>: View {
    
    @FetchRequest var fetchRequest: FetchedResults<T>
    
    // this is our content closure; we'll call this once for each item in the list
    let content: (T) -> Content
    
    var body: some View {
        List(fetchRequest, id: \.self) { singer in
            self.content(singer)
        }
    }
    
    enum Predicate: String {
        case equal = "==", gt = ">=", lt = "<=", beginsWith = "BEGINSWITH"
    }
    
    init(filterKey: String, filterValue: String, predicate: Predicate, sortDescriptors: [SortDescriptor<T>] = [], @ViewBuilder content: @escaping (T) -> Content) {
        _fetchRequest = FetchRequest<T>(sortDescriptors: sortDescriptors, predicate: NSPredicate(format: "%K \(predicate.rawValue) %@", filterKey, filterValue))
        self.content = content
    }
}
