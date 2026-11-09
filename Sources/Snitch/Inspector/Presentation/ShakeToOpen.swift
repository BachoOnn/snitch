import CoreMotion

/// Opens the inspector when the device is shaken.
///
/// Reads the accelerometer instead of hooking into the app's windows, so it works
/// the same in any app. The Simulator has no accelerometer, so use the floating
/// button or ``Snitch/present()`` there.
@MainActor
enum ShakeToOpen {
    private static let motion = CMMotionManager()
    private static var detector = ShakeDetector()

    static func enable() {
        guard motion.isAccelerometerAvailable, !motion.isAccelerometerActive else { return }
        motion.accelerometerUpdateInterval = 1.0 / 30
        motion.startAccelerometerUpdates(to: .main) { data, _ in
            guard let data else { return }
            MainActor.assumeIsolated { handle(data) }
        }
    }

    static func disable() {
        motion.stopAccelerometerUpdates()
        detector = ShakeDetector()
    }

    private static func handle(_ data: CMAccelerometerData) {
        let a = data.acceleration
        if detector.record(x: a.x, y: a.y, z: a.z, at: data.timestamp) {
            Snitch.present()
        }
    }
}
