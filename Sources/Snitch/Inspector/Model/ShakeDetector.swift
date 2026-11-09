/// Tells a shake apart from ordinary movement in a stream of accelerometer samples.
///
/// A shake is a few sharp jolts close together. Each time the force rises past
/// `threshold`, that counts as one jolt; enough jolts within `window` make a shake.
struct ShakeDetector {
    /// The force, in g, a jolt must reach. Holding the phone still reads about 1 g.
    var threshold = 2.0
    /// How many jolts make a shake.
    var requiredJolts = 3
    /// How close together, in seconds, the jolts must be.
    var window = 1.0
    /// How long, in seconds, to ignore movement after a shake.
    var cooldown = 1.5

    private var jolts: [Double] = []
    private var aboveThreshold = false
    private var lastShake = -Double.infinity

    /// Adds one sample and returns `true` when it completes a shake.
    ///
    /// - Parameters:
    ///   - x: Acceleration along the x axis, in g. Likewise for `y` and `z`.
    ///   - time: When the sample was taken, in seconds.
    mutating func record(x: Double, y: Double, z: Double, at time: Double) -> Bool {
        let isAbove = (x * x + y * y + z * z).squareRoot() >= threshold
        defer { aboveThreshold = isAbove }
        guard isAbove, !aboveThreshold, time - lastShake >= cooldown else { return false }

        jolts = jolts.filter { time - $0 <= window } + [time]
        guard jolts.count >= requiredJolts else { return false }
        jolts = []
        lastShake = time
        return true
    }
}
