//
//  AstronautView.swift
//  Moonshot
//
//  Created by Patrick Battisti Forsthofer on 16/01/22.
//

import SwiftUI

struct AstronautView: View {
    var astronaut: Astronaut
    
    var body: some View {
        ScrollView {
                    VStack {
                        Image(astronaut.id)
                            .resizable()
                            .scaledToFit()

                        Text(astronaut.description)
                            .padding()
                    }
                }
                .background(.darkBackground)
                .navigationTitle(astronaut.name)
                .navigationBarTitleDisplayMode(.inline)
    }
}

struct AstronautView_Previews: PreviewProvider {
    static let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")

        static var previews: some View {
            AstronautView(astronaut: astronauts["aldrin"]!)
                .preferredColorScheme(.dark)
        }
}
