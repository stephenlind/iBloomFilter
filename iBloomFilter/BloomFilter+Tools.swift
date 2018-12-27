/**
 Pure functions for use in Blom filter calculations
 */
extension BloomFilter {

    /**
     Given a filter of a certain byte size and element count, compute the optimal
     number of hash functions (key bits) to be inserted per element.
     - parameter byteSize: Size in bytes allocated to the bloom filter's bitfield
     - parameter elementCount: Number of elements that are expected in this filter.
     - returns:  Number of hashes (k) to be
     */
    static func computeHashCount(byteSize: Int, elementCount: Int) -> Int {
        let minHashCount = 1
        let maxHashCount = Int.max

        let bitFieldSize = byteSize * 8
        var hashCount = Int((Double(bitFieldSize) / Double(elementCount)) * log(2.0))
        hashCount = max(hashCount, minHashCount)
        hashCount = min(hashCount, maxHashCount)
        return hashCount
    }

    /**
     Given a completed filter with an optimal hash function count,
     compute the expected false positive rate
     - parameter byteSize: Size in bytes allocated to the bloom filter's bitfield
     - parameter elementCount: Number of elements in the filter
     - returns:  Expected false-positive rate (between 0.0 and 1.0)
     */
    static func computeFalsePositiveRate(byteSize: Int, elementCount: Int) -> Double {
        // Assuming optimal hash function count,
        // the false positive rate should be 1 - (1 - 1 / m)^n,
        // where m is the size of the bitfield and n is the number of elements
        let singleElementFalsePositive = 1 - 1 / Double(byteSize * 8)
        return 1 - pow(singleElementFalsePositive, Double(elementCount))
    }

    static func valueforFlagIndex(flagIndex: Int) -> Int {
        let value = pow(Double(2), Double(flagIndex))
        return Int(value)
    }

    /**
     Compute a fast, non-cryptographic hash of a given seed
     - parameter data: Data to be hashed
     - parameter seed: Seed for this hash
     - returns:  Computed hash, as UInt64
     */
    static func computeHash(data: Data, seed: UInt64) -> UInt64 {
        var hash = XXHash(seed: seed)
        hash.update(buffer: Array(data))
        return hash.digest()
    }
}
