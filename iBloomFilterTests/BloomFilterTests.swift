import XCTest
import iBloomFilter

class BloomFilterTests: XCTestCase {

    /**
     Verify that a constructed bloom filter has an expected size
     and is all zeroes.
     */
    func testBloomFilterInitialization() {
        let size = 1024
        let filter = BloomFilterDefault(size: size)

        let data = filter.filterData
        for i in 0..<size - 1 {
            let range = Range(i..<i+1)
            let byte = data.subdata(in: range)
            let byteInt = Array(byte).first
            XCTAssertEqual(byteInt, 0)
        }
    }

    func testPositiveMatches() {
        let size = 1024 * 1024 // 1 MB
        let filter = BloomFilterDefault(size: size)
        let count = 100
        for _ in 0..<count {
        let match = UUID().uuidString.data(using: .utf8)!
            filter.addMatch(data: match)
            XCTAssertTrue(filter.possibleMatch(data: match))
        }
    }
}
