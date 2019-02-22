import Foundation

public class BloomFilter : BloomFilterProtocol {
    // MARK: Public

    /**
     Create a new empty filter with a given size (in bytes)
     - parameter size: fixed size of the filter, in bytes.
     - parameter capacity: capacity of this filter, used to calculate hash count
     */
    public required init(size: Int, capacity: Int) {
        self.bitfield = [UInt8](repeating: 0, count: size)
        self.hashCount = BloomFilter.computeHashCount(byteSize: size,
                                                      elementCount: capacity)
    }

    /**
     Re-create an existing filter from data and element count
     - parameter size: fixed size of the filter, in bytes.
     - parameter capacity: capacity of this filter, used to calculate hash count
     - parameter elementCount: actual number of elements in this filter
     */
    required public convenience init(data: Data, capacity: Int, elementCount: Int) {
        self.init(size: data.count, capacity: elementCount)
        self.bitfield = Array(data)
        self.elementCount = elementCount
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

    public var data: Data {
        get {
            return Data(self.bitfield)
        }

    }

    // MARK: Private

    private var bitfield: [UInt8]

    fileprivate func checkBitIndex(bitIndex: UInt64, set: Bool) -> Bool {
        // convert bits to bytes
        let byteIndex = self.byteIndexWithBit(bitIndex: Int(bitIndex))
        let originalByte = self.bitfield[byteIndex]

        let intraByteIndex = UInt8(bitIndex % 8)
        let flagValue = BloomFilter.valueforFlagIndex(flagIndex: intraByteIndex)
        let hasFlag: Bool = (originalByte & flagValue) == flagValue

        if set && !hasFlag  {
            let newByte = originalByte + UInt8(flagValue)
            self.bitfield.replaceSubrange(byteIndex...byteIndex, with: [newByte])
        }

        return hasFlag
    }

    fileprivate func maxByteIndex() -> UInt64 {
        return UInt64(self.bitfield.count)
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

