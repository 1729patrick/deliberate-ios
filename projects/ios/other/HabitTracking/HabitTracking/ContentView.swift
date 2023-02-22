//
//  ContentView.swift
//  HabitTracking
//
//  Created by Patrick Battisti Forsthofer on 25/01/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var activities = Activities()
    @State private var showingAddActivity = false
    
    var body: some View {
        NavigationView {
            List(activities.items){ activity in
                NavigationLink{
                    ActivityDetailView(activity: activity, activities: activities)
                } label: {
                    VStack(alignment: .leading) {
                        Text(activity.title)
                            .font(.headline)
                        Text(activity.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
            }
            .toolbar {
                Button {
                    showingAddActivity = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView(activities: activities)
            }
            .navigationTitle("Habit tracking")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
