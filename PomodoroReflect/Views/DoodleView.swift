//
//  DoodleView.swift
//  PomodoroReflect
//
//  Created by Yiyi Huang on 3/25/25.
//


import SwiftUI

struct DoodleView: View {
    @State private var lines: [Line] = []
    @State private var currentLine = Line(points: [])

    var body: some View {
        VStack {
            Text("Begin doodling simple shapes and patterns")
                .font(.headline)
                .padding()

            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    if let firstPoint = line.points.first {
                        path.move(to: firstPoint)
                        for point in line.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    context.stroke(path, with: .color(.blue), lineWidth: 3)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentLine.points.append(value.location)
                        lines.append(currentLine)
                    }
                    .onEnded { _ in
                        lines.append(currentLine)
                        currentLine = Line(points: [])
                    }
            )
            .frame(height: 700)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding()
        }
    }
}

struct Line {
    var points: [CGPoint]
}

struct DoodleView_Previews: PreviewProvider {
    static var previews: some View {
        DoodleView()
    }
}
