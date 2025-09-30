import Foundation
import CoreMotion

@MainActor
final class MotionVM: ObservableObject {
    @Published var rollDeg: Double = 0
    @Published var pitchDeg: Double = 0
    @Published var yawDeg: Double = 0
    @Published var qx: Double = 0
    @Published var qy: Double = 0
    @Published var qz: Double = 0
    @Published var qw: Double = 0
    @Published var sampleHz: Double = 0
    @Published var usingDemo: Bool = false
    @Published var errorMessage: String? = nil

    var alpha: Double = 0.15
    private var offRoll: Double = 0
    private var offPitch: Double = 0
    private var offYaw: Double = 0

    private let mgr = CMMotionManager()
    private let queue = OperationQueue()
    private var lastTimestamp: TimeInterval?
    private var demoTask: Task<Void, Never>?

    func start(updateHz: Double = 60, demo: Bool? = nil) {
        stop()
        if let d = demo { usingDemo = d }
        errorMessage = nil

        if usingDemo {
            guard mgr.isDeviceMotionAvailable else {
                errorMessage = "Device Motion not available. Enable Demo mode."
                usingDemo = true
                startDemo(updateHz: updateHz)
                return
            }
        }

        mgr.deviceMotionUpdateInterval = 1.0 / updateHz
        lastTimestamp = nil
        mgr.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: queue) { [weak self] motion, error in
            guard let self else { return }
            if let error { Task { @MainActor in self.errorMessage = error.localizedDescription } }
            guard let m = motion else { return }

            let ts = m.timestamp
            let dt = self.lastTimestamp.map { ts - $0 } ?? (1.0 / updateHz)
            self.lastTimestamp = ts
            let hz = dt > 0 ? 1.0 / dt : updateHz

            let r = m.attitude.roll.toDegrees
            let p = m.attitude.pitch.toDegrees
            let y = m.attitude.yaw.toDegrees
            let q = m.attitude.quaternion

            let newRoll = self.lowPass(current: r - self.offRoll, previous: self.rollDeg)
            let newPitch = self.lowPass(current: p - self.offPitch, previous: self.pitchDeg)
            let newYaw = self.lowPass(current: y - self.offYaw, previous: self.yawDeg)

            Task { @MainActor in
                self.rollDeg = newRoll
                self.pitchDeg = newPitch
                self.yawDeg = newYaw
                self.qx = q.x; self.qy = q.y; self.qz = q.z; self.qw = q.w
                self.sampleHz = hz
            }
        }
    }

    func stop() {
        mgr.stopDeviceMotionUpdates()
        demoTask?.cancel(); demoTask = nil
        lastTimestamp = nil
    }

    func calibrate() {
        offRoll += rollDeg; offPitch += pitchDeg; offYaw += yawDeg
    }

    private func startDemo(updateHz: Double) {
        demoTask = Task { [weak self] in
            guard let self else { return }
            var t: Double = 0
            let dt = 1.0 / updateHz
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(dt * 1_000_000_000))
                t += dt
                let r = sin(t * 1.2) * 8
                let p = cos(t * 0.9) * 6
                await MainActor.run {
                    self.rollDeg = self.lowPass(current: r, previous: self.rollDeg)
                    self.pitchDeg = self.lowPass(current: p, previous: self.pitchDeg)
                    self.yawDeg = 0
                    self.qx = 0; self.qy = 0; self.qz = 0; self.qw = 1
                    self.sampleHz = updateHz
                }
            }
        }
    }

    private func lowPass(current: Double, previous: Double) -> Double {
        previous + alpha * (current - previous)
    }
}

private extension Double {
    var toDegrees: Double { self * 180.0 / .pi }
}
