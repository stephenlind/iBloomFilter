import Foundation

public class BloomFilter : BloomFilterProtocol {

    // MARK: Public

    /**
     Create a new empty filter with a given size (in bytes)
     - parameter size: fixed size of the filter, in bytes.
     */
    public required init(size: Int, capacity: Int) {
        self.filterData = [UInt8](repeating: 0, count: size)
        self.hashCount = BloomFilter.computeHashCount(byteSize: size,
                                                      elementCount: capacity)
    }

    public func check(data: Data) -> Bool {
        let hashes = self.computeHashes(data: data,
                                        hashCount: self.hashCount,
                                        modulus: self.maxBitIndex())
        for hash in hashes {
            if !self.checkBitIndex(bitIndex: hash, set: false) {
                return false
            }
        }
        return true
    }

    public func add(data: Data) {
        let hashes = self.computeHashes(data: data,
                                        hashCount: self.hashCount,
                                        modulus: self.maxBitIndex())
        for hash in hashes {
            _ = self.checkBitIndex(bitIndex: hash, set: true)
        }
        self.elementCount += 1
    }

    /**
     Count of the elements added to the filter
     */
    public var elementCount: Int = 0

    /**
     Count of the elements added to the filter
     */
    public let hashCount: Int

    /**
     Compute a checksum for a given piece of data
     - Parameter data: Data to checksum
     - Returns: Checksum as an integer. If this integer is larger than your bloom filter size, the modulus will be taken for its checksum.
     */
    public func computeHashes(data: Data, hashCount: Int, modulus: UInt64) -> [UInt64] {
        // Simple implemetation of crc32, this effectively limits
        // the size to ~536 MB
        var hashes = [UInt64]()
        for i in 0..<hashCount {
            let hash = BloomFilter.computeHash(data: data, seed: UInt64(i))
            let hashMod = UInt64(hash) % modulus
            hashes.append(hashMod)
        }
        return hashes
    }

    // MARK: Private

    var filterData: [UInt8]

    fileprivate func checkBitIndex(bitIndex: UInt64, set: Bool) -> Bool {
        // convert bits to bytes
        let byteIndex = self.byteIndexWithBit(bitIndex: Int(bitIndex))
        let originalByte = self.filterData[byteIndex]

        let intraByteIndex = Int(bitIndex % 8)
        let flagValue = BloomFilter.valueforFlagIndex(flagIndex: intraByteIndex)
        let stripFlagValue = BloomFilter.valueforFlagIndex(flagIndex: intraByteIndex + 1)
        let byteStripHigherFlags = Int(originalByte) % stripFlagValue
        let hasFlag: Bool = (byteStripHigherFlags / flagValue) > 0

        if set && !hasFlag  {
            let newByte = originalByte + UInt8(flagValue)
            self.filterData.replaceSubrange(byteIndex...byteIndex, with: [newByte])
        }

        return hasFlag
    }

    fileprivate func maxByteIndex() -> UInt64 {
        return UInt64(self.filterData.count)
    }

    fileprivate func maxBitIndex() -> UInt64 {
        return self.maxByteIndex() * 8
    }

    fileprivate func byteIndexWithBit(bitIndex: Int) -> Int {
        let modIndex = UInt64(bitIndex) % self.maxBitIndex()
        let byteIndex = modIndex / 8
        return Int(byteIndex)
    }
}

