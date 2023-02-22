//
//  AddActivityView.swift
//  HabitTracking
//
//  Created by Patrick Battisti Forsthofer on 25/01/22.
//

import SwiftUI

struct AddActivityView: View {
    @ObservedObject var activities: Activities
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title )
                TextField("Description", text: $description )
            }
            .navigationTitle("Add new Activity")
            .toolbar {
                Button("Save") {
                    let item = Activity(title: title, description: description)
                    activities.items.append(item)
                    dismiss()
                }
            }
        }
    }
}

struct AddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        AddActivityView(activities: Activities())
    }
}
