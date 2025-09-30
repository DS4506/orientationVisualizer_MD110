import SwiftUI

struct BubbleLevelView: View {
    @ObservedObject var vm: MotionVM
    var targetTolerance: Double = 3
    var radius: CGFloat = 110

    // Explicit animation type (prevents Duration→Double inference errors)
    private let bubbleAnim: Animation = .easeOut(duration: 0.08)

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(lineWidth: 2)
                .foregroundStyle(.secondary)
                .frame(width: radius * 2, height: radius * 2)

            // Crosshairs
            Path { p in
                p.move(to: CGPoint(x: -radius, y: 0))
                p.addLine(to: CGPoint(x:  radius, y: 0))
                p.move(to: CGPoint(x: 0, y: -radius))
                p.addLine(to: CGPoint(x: 0, y:  radius))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
            .foregroundStyle(.tertiary)
            .frame(width: radius * 2, height: radius * 2)

            // Bubble
            Circle()
                .fill(isLevel ? Color.green.opacity(0.75) : Color.orange.opacity(0.75))
                .frame(width: 24, height: 24)
                .shadow(radius: 2)
                .offset(bubbleOffset)
                .animation(bubbleAnim, value: vm.rollDeg)
                .animation(bubbleAnim, value: vm.pitchDeg)
                .frame(width: radius * 2, height: radius * 2)
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 4) {
                Text(String(format: "roll %.1f°   pitch %.1f°", vm.rollDeg, vm.pitchDeg))
                    .font(.caption)
                    .monospacedDigit()
                Text(String(format: "Hz = %.0f", vm.sampleHz))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
        .accessibilityLabel("Bubble level")
    }

    // MARK: - Helpers

    private var isLevel: Bool {
        abs(vm.rollDeg) <= targetTolerance && abs(vm.pitchDeg) <= targetTolerance
    }

    private var bubbleOffset: CGSize {
        let scale: CGFloat = radius / 15
        let x = CGFloat(vm.rollDeg) * scale
        let y = CGFloat(-vm.pitchDeg) * scale   // screen Y grows downward
        let dist = sqrt(x * x + y * y)
        if dist > radius {
            let k = radius / dist
            return CGSize(width: x * k, height: y * k)
        }
        return CGSize(width: x, height: y)
    }
}

// Use classic PreviewProvider (works across Xcode versions)
struct BubbleLevelView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleLevelView(vm: MotionVM())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
