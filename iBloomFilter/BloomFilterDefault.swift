import Foundation
import zlib

public class BloomFilterDefault {

    // MARK: BloomFilter Protocol

    public var filterData: Data

    public var count: Int = 0

    public init(size: Int) {
        let bytes = [UInt8](repeating: 0, count: size)
        let data = Data(bytes)
        self.filterData = data
    }

    public func possibleMatch(data: Data) -> Bool {
        let checksum = self.computeChecksum(data: data)
        return self.checkBitAtIndex(bitIndex: checksum, set: false)
    }

    public func addMatch(data: Data) {
        let checksum = self.computeChecksum(data: data)
        _ = self.checkBitAtIndex(bitIndex: checksum, set: true)
        self.count += 1
    }

    public func computeChecksum(data: Data) -> UInt64 {
        // Simple implemetation of crc32, this effectively limits
        // the size to ~536 MB
        let nsdata = data as NSData
        let ptr = nsdata.bytes.assumingMemoryBound(to: UInt8.self)
        let crc = crc32(0, ptr, uint(nsdata.length))
        return UInt64(crc) % self.maxByteIndex()
    }

    fileprivate func checkBitAtIndex(bitIndex: UInt64, set: Bool) -> Bool {
        // convert bits to bytes
        let byteIndex = self.byteIndexWithBit(bitIndex: Int(bitIndex))
        let range = Range(byteIndex...byteIndex)
        let originalByte = Array(self.filterData.subdata(in: range)).first!

        let intraByteIndex = Int(bitIndex % 8)
        let flagValue = self.byteValueforFlagIndex(flagIndex: intraByteIndex)
        let stripFlagValue = self.byteValueforFlagIndex(flagIndex: intraByteIndex + 1)
        let byteStripHigherFlags = Int(originalByte) % stripFlagValue
        let hasFlag: Bool = (byteStripHigherFlags / flagValue) > 0

        if set && !hasFlag  {
            let newByte = originalByte + UInt8(flagValue)
            let newData = Data([newByte])
            self.filterData.replaceSubrange(range, with: newData)
        }

        return hasFlag
    }

    fileprivate func maxByteIndex() -> UInt64 {
        return UInt64(self.filterData.count)
    }

    fileprivate func maxBitIndex() -> UInt64 {
        return self.maxByteIndex() * 8
    }

    fileprivate func byteValueforFlagIndex(flagIndex: Int) -> Int {
        let value = pow(Double(2), Double(flagIndex))
        return Int(value)
    }

    fileprivate func byteIndexWithBit(bitIndex: Int) -> Int {
        let modIndex = UInt64(bitIndex) % self.maxBitIndex()
        let byteIndex = modIndex / 8
        return Int(byteIndex)
    }
}

