import SwiftUI

struct OrientationRootView: View {
    @StateObject private var vm = MotionVM()
    @State private var hz: Double = 60
    @State private var showCube: Bool = false
    @State private var demoMode: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                // Bubble Level
                BubbleLevelView(vm: vm, targetTolerance: 3, radius: 110)
                    .padding(.top, 8)

                // Roll / Pitch / Yaw readout
                VStack(spacing: 6) {
                    Text(String(format: "roll %.1f°   pitch %.1f°   yaw %.1f°",
                                vm.rollDeg, vm.pitchDeg, vm.yawDeg))
                        .font(.system(.body, design: .monospaced))
                    Text(String(format: "Hz = %.0f", vm.sampleHz))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Orientation cube
                if showCube {
                    OrientationCubeView(qx: vm.qx, qy: vm.qy, qz: vm.qz, qw: vm.qw)
                        .frame(height: 220)
                        .padding(.vertical, 4)
                        .transition(.opacity.combined(with: .scale))
                }

                // Toggles
                VStack(spacing: 12) {
                    HStack {
                        Toggle("Demo mode", isOn: $demoMode)
                            .onChange(of: demoMode) { _, new in
                                vm.start(updateHz: hz, demo: new)
                            }
                        Spacer()
                        Toggle("3D cube", isOn: $showCube)
                            .toggleStyle(.switch)
                    }

                    // Slider for update frequency
                    HStack(spacing: 12) {
                        Text("Hz")
                        Slider(value: $hz, in: 15...100, step: 15)
                            .onChange(of: hz) { _, new in
                                vm.start(updateHz: new, demo: demoMode)
                            }
                        Text("\(Int(hz))")
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 36, alignment: .trailing)
                    }

                    // Control buttons
                    HStack(spacing: 12) {
                        Button("Start") { vm.start(updateHz: hz, demo: demoMode) }
                            .buttonStyle(.borderedProminent)
                        Button("Stop") { vm.stop() }
                            .buttonStyle(.bordered)
                        Button("Calibrate") { vm.calibrate() }
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)

                // Error messages
                if let msg = vm.errorMessage {
                    Text(msg)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Orientation Visualizer")
            .onAppear { vm.start(updateHz: hz, demo: demoMode) }
            .onDisappear { vm.stop() }
        }
    }
}

#Preview {
    OrientationRootView()
}
