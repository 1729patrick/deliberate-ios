//
//  ContentView.swift
//  UnitConversions
//
//  Created by Patrick Battisti Forsthofer on 21/12/21.
//

import SwiftUI

struct ContentView: View {
    @State var selectedUnit = 0
    
    @State var fromUnit: Dimension = UnitDuration.seconds
    @State var toUnit: Dimension = UnitDuration.minutes
    
    @State var fromValue: Double = 0.0
    
    var unitTypes = ["Duration", "Length", "Temperature"]
    
    let units: [[Dimension]] = [
        [UnitDuration.seconds, UnitDuration.minutes, UnitDuration.hours],
        [UnitLength.kilometers, UnitLength.meters],
        [UnitTemperature.celsius, UnitTemperature.kelvin, UnitTemperature.fahrenheit]
        
    ]
    
    let formatter = MeasurementFormatter()
    
    
    var result: String {
        let from = Measurement(value: fromValue, unit: fromUnit)
        let to = from.converted(to: toUnit)
        
        
        return "\(to.formatted())"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Amount to convert", value: $fromValue, format: .number )
                } header: {
                    Text("Amount to convert")
                }
                
                Section {
                    Picker("Unit type", selection: $selectedUnit) {
                        ForEach(0..<unitTypes.count, id: \.self){
                            Text(unitTypes[$0])
                        }
                    }.pickerStyle(.segmented)
                    Picker("From unit", selection: $fromUnit) {
                        ForEach(units[selectedUnit], id: \.self){
                            Text(formatter.string(from: $0).capitalized)
                        }
                    }
                    Picker("To unit", selection: $toUnit) {
                        ForEach(units[selectedUnit], id: \.self){
                            Text(formatter.string(from: $0).capitalized)
                        }
                    }
                }
                
                Section {
                    Text(result)
                } header: {
                    Text("Result")
                }
                .navigationTitle("Converter")
                .onChange(of: selectedUnit){ newSelection in
                    let newUnits = units[newSelection]
                    fromUnit = newUnits[0]
                    toUnit = newUnits[newUnits.count - 1]
                }
            }
        }
    }
    
    init(){
        formatter.unitStyle = .long
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
