import SwiftUI

class BoxBreathingAnimation: ObservableObject {
    @Published var isAnimating = false
    @Published var animationProgress: CGFloat = 0
    let boxSize: CGFloat = 200
    
    func startAnimation() {
        isAnimating = true
    }
    
    func stopAnimation() {
        isAnimating = false
    }
}

struct BoxBreathingAnimationView: View {
    @ObservedObject var animation: BoxBreathingAnimation
    @State private var progress: CGFloat = 0
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: animation.boxSize, height: animation.boxSize)
                
                // Add breathing instruction text
                Text(getCurrentInstruction())
                    .font(.title3)
                    .foregroundColor(.black)
                    .frame(width: animation.boxSize, height: animation.boxSize)
                
                Circle()
                    .fill(Color.customBlue)
                    .frame(width: 20, height: 20)
                    .position(
                        x: getCirclePosition().x + (geometry.size.width - animation.boxSize) / 2,
                        y: getCirclePosition().y
                    )
            }
            .padding(.bottom, 40)
            .onReceive(timer) { _ in
                if animation.isAnimating {
                    progress += 0.004  // 1 unit / (4 seconds * 60 fps)
                    if progress >= 4 {
                        progress = 0
                    }
                }
            }
            .onChange(of: animation.isAnimating) { oldValue, newValue in
                if !newValue {
                    progress = 0
                }
            }
        }
    }
    
    private func getCurrentInstruction() -> String {
        let currentProgress = progress.truncatingRemainder(dividingBy: 4)
        
        switch currentProgress {
        case 0..<1:
            return "Breathe In"
        case 1..<2:
            return "Hold"
        case 2..<3:
            return "Breathe Out"
        case 3..<4:
            return "Hold"
        default:
            return "Breathe In"
        }
    }
    
    private func getCirclePosition() -> CGPoint {
        let currentProgress = progress.truncatingRemainder(dividingBy: 4)
        let circleRadius: CGFloat = 10  // Half of circle's width
        
        switch currentProgress {
        case 0..<1: // Top edge: left to right
            return CGPoint(x: currentProgress * animation.boxSize, y: 0)
        case 1..<2: // Right edge: top to bottom
            return CGPoint(x: animation.boxSize, y: (currentProgress - 1) * animation.boxSize)
        case 2..<3: // Bottom edge: right to left
            return CGPoint(x: animation.boxSize - ((currentProgress - 2) * animation.boxSize), y: animation.boxSize)
        case 3..<4: // Left edge: bottom to top
            return CGPoint(x: 0, y: animation.boxSize - ((currentProgress - 3) * animation.boxSize))
        default:
            return CGPoint(x: 0, y: 0)
        }
    }
}
