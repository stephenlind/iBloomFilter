import XCTest
@testable import iBloomFilter

class BloomFilterTests: XCTestCase {

    /**
     Verify that a constructed bloom filter has an expected size
     and is all zeroes.
     */
    func testBloomFilterInitialization() {
        let size = 1024
        let filter = BloomFilter(size: size, capacity: 100)

        let data = filter.filterData
        for i in 0..<size - 1 {
            let range = Range(i..<i+1)
            let byte = data.subdata(in: range)
            let byteInt = Array(byte).first
            XCTAssertEqual(byteInt, 0)
        }
    }

    /**
     Verify that a large number of positive matches all are labeled as 'maybe'
     */
    func testPositiveMatches() {
        let size = 1024 * 1024
        let count = 10000
        let filter = BloomFilter(size: size, capacity: count)
        var missed = 0
        for _ in 0..<count {
            let match = UUID().uuidString.data(using: .utf8)!
            filter.add(data: match)
            let possibleMatch = filter.check(data: match)
            XCTAssertTrue(possibleMatch)
            if !possibleMatch {
                missed += 1
            }
        }
        XCTAssertEqual(missed, 0)
    }

    /**
     Verify that the false positive rate is within expectations
     */
    func testFalsePositiveRate() {
        let size = 1024 * 1024 // 1 MB
        let count = 10000
        let filter = BloomFilter(size: size, capacity: count)
        var falsePositives = 0
        for _ in 0..<count {
            let match = UUID().uuidString.data(using: .utf8)!
            filter.add(data: match)

            let nonMatch = UUID().uuidString.data(using: .utf8)!
            let falsePositive = filter.check(data: nonMatch)
            if falsePositive {
                falsePositives += 1
            }
        }
        XCTAssertTrue(falsePositives > 0)
        let falsePositiveRate = BloomFilter.computeFalsePositiveRate(byteSize: size,
                                                                     elementCount: count)
        let expFalsePositives = falsePositiveRate * Double(count) * 10.0
        XCTAssertTrue(Double(falsePositives) < expFalsePositives)
    }
}
