import Foundation

class BloomFilterDefault {

    // MARK: BloomFilter Protocol

    var filterData: Data

    convenience init(size: Int) {
        let zeroBytes = calloc(0, size)!
        let data = Data(bytes: zeroBytes, count: size)
        self.init(data: data)
    }

    init(data: Data) {
        self.filterData = data
    }

    func possibleMatch(data: Data) -> Bool {
        return false
    }

    func computeChecksum(data: Data) -> Int64 {
        return 0
    }
}
