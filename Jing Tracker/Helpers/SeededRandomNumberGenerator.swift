import Foundation

/// A deterministic random number generator using the Xorshift64 algorithm.
/// Passing the same seed always produces the same sequence of values,
/// which makes preview data and tests fully reproducible.
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // Avoid a zero state — xorshift64 would produce only zeros.
        self.state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
