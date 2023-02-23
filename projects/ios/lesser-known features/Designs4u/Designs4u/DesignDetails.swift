//
//  DesignDetails.swift
//  Designs4u
//
//  Created by Patrick Battisti Forsthofer on 23/02/23.
//

import SwiftUI

struct DesignerDetails: View {
    var person: Person

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                AsyncImage(url: person.photo, scale: 3)
                    .overlay(
                        Rectangle()
                            .strokeBorder(.primary.opacity(0.2), lineWidth: 4)
                    )
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 10) {
                    Text(person.displayName)
                        .font(.largeTitle.bold())
                        .fontDesign(.rounded)

                    Text(person.bio)
                    Text(person.details)
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(person.tags, id: \.self) { tag in
                            Text(tag)
                                .padding(5)
                                .padding(.horizontal)
                                .background(.blue.gradient)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                }
                .mask(
                    LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .white, location: 0.05), .init(color: .white, location: 0.95), .init(color: .clear, location: 1)], startPoint: .leading, endPoint: .trailing)
                )
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("**Experience:** ^[\(person.experience) years](inflect: true)")
                    Text("**Rate:** $\(person.rate)")
                    Text(.init("**Contact:** \(person.email)"))
                }
                .padding()
            }
            .padding(.vertical)
        }
        .presentationDetents([.medium, .large])
    }
}

var previews: some View {
    DesignerDetails(person: .example)
}
