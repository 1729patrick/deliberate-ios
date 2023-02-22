//
//  ActivityDetailView.swift
//  HabitTracking
//
//  Created by Patrick Battisti Forsthofer on 25/01/22.
//

import SwiftUI

struct ActivityDetailView: View {
    @State var activity: Activity
    @ObservedObject var activities: Activities
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Description: \(activity.description)")
                    .navigationTitle(activity.title)
                
                Text("Completed: \((activity.completed).formatted())%")
                Slider(value: $activity.completed, in: 0...100, step: 1)
                    .padding([.horizontal, .top])
            }
            .toolbar {
                Button("Save", action: didSave)
            }
        }
        
    }
    
    func didSave() {
        let index = activities.items.firstIndex(where: { $0.id == activity.id })
        
        activities.items[index!] = activity
    }
}

struct ActivityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityDetailView(activity: Activity(title: "", description: ""), activities: Activities())
    }
}
