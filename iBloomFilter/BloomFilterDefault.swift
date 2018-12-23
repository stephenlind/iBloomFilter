import Foundation
import zlib

public class BloomFilterDefault {

    // MARK: BloomFilter Protocol

    public var filterData: Data

    public convenience init(size: Int) {
        let bytes = [UInt8](repeating: 0, count: size)
        let data = Data(bytes)
        self.init(data: data)
    }

    public init(data: Data) {
        self.filterData = data
    }

    public func possibleMatch(data: Data) -> Bool {
        let checksum = self.computeChecksum(data: data)
        return self.checkBitAtIndex(bitIndex: checksum, set: false)
    }

    public func addMatch(data: Data) {
        let checksum = self.computeChecksum(data: data)
        _ = self.checkBitAtIndex(bitIndex: checksum, set: true)
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
        let byteIndex = Int((bitIndex / 8) % self.maxByteIndex())
        let range = Range(byteIndex..<(byteIndex + 1))
        let byte = Array(self.filterData.subdata(in: range)).first!

        let addBitIndex = Int(bitIndex % 8)
        let addBitValue = self.byteWithBitIndex(bitIndex: addBitIndex)
        let modBitValue = UInt8(addBitIndex < 7 ? addBitIndex + 1 : 0)

        let byteStripHigherFlags = UInt8(byte % modBitValue)
        let hasFlag: Bool = (byteStripHigherFlags / addBitValue) > 0

        if set && !hasFlag  {
            let newByte = byte + addBitValue
            let newData = Data([newByte])
            self.filterData.replaceSubrange(range, with: newData)
        }

        return hasFlag
    }

    fileprivate func maxByteIndex() -> UInt64 {
        return UInt64(self.filterData.count)
    }

    fileprivate func byteWithBitIndex(bitIndex: Int) -> UInt8 {
        return UInt8(pow(Double(2), Double(bitIndex)))
    }
}

