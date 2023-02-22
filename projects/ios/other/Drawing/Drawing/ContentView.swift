//
//  ContentView.swift
//  Drawing
//
//  Created by Patrick Battisti Forsthofer on 18/01/22.
//

import SwiftUI


struct Arrow: Shape {
    var lineHeight = 0.4
    var pointerLineLength = 30.0
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(Double(lineHeight), Double(pointerLineLength))
        }
        set {
            lineHeight = newValue.first
            pointerLineLength = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let start = CGPoint(x: rect.midX, y: rect.midY)
        let end = CGPoint(x: rect.midX, y: rect.midY * (1 + lineHeight))
        
        path.move(to: start)
        path.addLine(to: end)
        
        let arrowAngle = Double(Double.pi / 4)
        
        let startEndAngle = atan((end.y - start.y) / (end.x - start.x)) + ((end.x - start.x) < 0 ? CGFloat(Double.pi) : 0)
        let arrowLine1 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
        let arrowLine2 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))
        
        path.addLine(to: arrowLine1)
        path.move(to: end)
        path.addLine(to: arrowLine2)
        
        return path
    }
}

struct ColorCyclingRectangle: View {
    var amount = 0.0
    var steps = 100

    var body: some View {
        ZStack {
            ForEach(0..<steps) { value in
                Rectangle()
                    .inset(by: Double(value))
                    .strokeBorder(color(for: value, brightness: 1), lineWidth: 2)
            }
        }
    }

    func color(for value: Int, brightness: Double) -> Color {
        var targetHue = Double(value) / Double(steps) + amount

        if targetHue > 1 {
            targetHue -= 1
        }

        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}

struct ContentView: View {
//    @State var lineHeight = 0.4
//    @State var pointerLineLength = 30.0
//
//    var body: some View {
//        Arrow(lineHeight: lineHeight, pointerLineLength: pointerLineLength)
//            .stroke(.indigo, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
//            .onTapGesture {
//                withAnimation {
//                    lineHeight = Double.random(in: -1...1)
//                    pointerLineLength = Double.random(in: 10...100)
//                }
//            }
//    }
    
    @State private var colorCycle = 0.0

       var body: some View {
           VStack {
               ColorCyclingRectangle(amount: colorCycle)
                   .frame(width: 300, height: 300)

               Slider(value: $colorCycle)
                   .padding([.horizontal])
           }
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
