//
//  ContentView.swift
//  Rendering
//
//  Created by Patrick Battisti Forsthofer on 24/02/23.
//

import SwiftUI

class SaveData: ObservableObject {
    @Published var highScore = 0
}

struct DisplayingView: View {
    @EnvironmentObject var saveData: SaveData

    var body: some View {
        print("In DisplayingView.body")
        return Text("Your high score is: \(saveData.highScore)")
    }

    init() {
        print("In DisplayingView.init")
    }
}

struct UpdatingView: View {
    @Environment(\.saveData) var saveData

    var body: some View {
        print("In UpdatingView.body")
        return Button("Add to High Score") {
            saveData.highScore += 1
        }
    }

    init() {
        print("In UpdatingView.init")
    }
}

struct ContentView: View {
    @State var saveData = SaveData()

    var body: some View {
        print("In ContentView.body")

        return VStack {
            UpdatingView()
            DisplayingView()
        }
        .environmentObject(saveData)
        .environment(\.saveData, saveData)
    }

    init() {
        print("In ContentView.init")
    }
}

struct SaveDataKey: EnvironmentKey {
    static var defaultValue = SaveData()
}

extension EnvironmentValues {
    var saveData: SaveData {
        get { self[SaveDataKey.self] }
        set { self[SaveDataKey.self] = newValue }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
