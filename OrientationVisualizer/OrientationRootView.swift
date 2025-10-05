import SwiftUI

struct OrientationRootView: View {
    @StateObject private var vm = MotionVM()
    @State private var hz: Double = 60
    @State private var showCube: Bool = true
    @State private var demoMode: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    // Bubble Level
                    BubbleLevelView(vm: vm, targetTolerance: 3, radius: 110)
                        .padding(.top, 8)

                    // Roll / Pitch / Yaw
                    HStack(spacing: 12) {
                        metricBox(title: "Roll",  value: vm.rollDeg,  unit: "°")
                        metricBox(title: "Pitch", value: vm.pitchDeg, unit: "°")
                        metricBox(title: "Yaw",   value: vm.yawDeg,   unit: "°")
                    }

                    // Quaternion
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quaternion").font(.caption).foregroundStyle(.secondary)
                        grid {
                            metric("qx", vm.qx)
                            metric("qy", vm.qy)
                            metric("qz", vm.qz)
                            metric("qw", vm.qw)
                        }
                    }

                    Toggle("Show 3D Cube", isOn: $showCube)

                    if showCube {
                        OrientationCubeView(qx: vm.qx, qy: vm.qy, qz: vm.qz, qw: vm.qw)
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 3)
                    }

                    Toggle("Demo mode", isOn: $demoMode)
                        .onChange(of: demoMode) { _, newValue in
                            vm.start(updateHz: hz, demo: newValue)
                        }

                    HStack {
                        Text("Update rate: \(Int(hz)) Hz")
                        Slider(value: $hz, in: 10...120, step: 5)
                            .onChange(of: hz) { _, new in
                                vm.start(updateHz: new, demo: demoMode)
                            }
                    }

                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Spacer(minLength: 0)
                }
                .padding()
            }
            .navigationTitle("Orientation Visualizer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Calibrate") { vm.calibrate() }
                }
            }
            .onAppear { vm.start(updateHz: hz, demo: demoMode) }
            .onDisappear { vm.stop() }
        }
    }

    @ViewBuilder
    private func grid<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) { content() }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func metric(_ label: String, _ value: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(String(format: "%.3f", value)).monospacedDigit()
        }
        .font(.callout)
    }

    @ViewBuilder
    private func metricBox(title: String, value: Double, unit: String) -> some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(String(format: "%.1f%@", value, unit))
                .font(.title3.monospacedDigit())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    OrientationRootView()
}
