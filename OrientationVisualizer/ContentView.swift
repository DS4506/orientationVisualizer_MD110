import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Full experience
            OrientationRootView()
                .tabItem { Label("Visualizer", systemImage: "gyroscope") }

            // Bubble level only
            LevelOnlyView()
                .tabItem { Label("Level", systemImage: "circle.grid.2x1") }

            // 3D cube only
            CubeOnlyView()
                .tabItem { Label("Cube", systemImage: "cube") }

            // About
            AboutView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
    }
}

private struct LevelOnlyView: View {
    @StateObject private var vm = MotionVM()
    @State private var hz: Double = 60
    @State private var demo: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                BubbleLevelView(vm: vm, targetTolerance: 3, radius: 120)

                HStack(spacing: 24) {
                    metricBox(title: "Roll", value: vm.rollDeg, unit: "°")
                    metricBox(title: "Pitch", value: vm.pitchDeg, unit: "°")
                }

                Toggle("Demo mode", isOn: $demo)
                    .onChange(of: demo) { _, new in vm.start(updateHz: hz, demo: new) }

                HStack {
                    Text("Hz \(Int(hz))")
                    Slider(value: $hz, in: 10...120, step: 5)
                        .onChange(of: hz) { _, new in vm.start(updateHz: new, demo: demo) }
                }

                if let err = vm.errorMessage {
                    Text(err).font(.footnote).foregroundStyle(.red).padding(.top, 4)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Bubble Level")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Calibrate") { vm.calibrate() }
                }
            }
            .onAppear { vm.start(updateHz: hz, demo: demo) }
            .onDisappear { vm.stop() }
        }
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

private struct CubeOnlyView: View {
    @StateObject private var vm = MotionVM()
    @State private var hz: Double = 60
    @State private var demo: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                OrientationCubeView(qx: vm.qx, qy: vm.qy, qz: vm.qz, qw: vm.qw)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 3)

                grid {
                    metric("qx", vm.qx)
                    metric("qy", vm.qy)
                    metric("qz", vm.qz)
                    metric("qw", vm.qw)
                }

                Toggle("Demo mode", isOn: $demo)
                    .onChange(of: demo) { _, new in vm.start(updateHz: hz, demo: new) }

                HStack {
                    Text("Hz \(Int(hz))")
                    Slider(value: $hz, in: 10...120, step: 5)
                        .onChange(of: hz) { _, new in vm.start(updateHz: new, demo: demo) }
                }

                if let err = vm.errorMessage {
                    Text(err).font(.footnote).foregroundStyle(.red).padding(.top, 4)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("3D Orientation")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Calibrate") { vm.calibrate() }
                }
            }
            .onAppear { vm.start(updateHz: hz, demo: demo) }
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
}

private struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Orientation Visualizer").font(.title2.bold())
                Text("Use the tabs to explore the bubble level and a 3D orientation cube. Turn on Demo mode if you are using the Simulator.")
                Text("Calibrate aligns the current device attitude as zero for roll and pitch.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

#Preview {
    ContentView()
}
