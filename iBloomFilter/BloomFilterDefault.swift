import Foundation

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
        return false
    }

    public func computeChecksum(data: Data) -> Int64 {
        return 0
    }
}
