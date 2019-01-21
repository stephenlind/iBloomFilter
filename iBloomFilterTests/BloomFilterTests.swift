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
        let data = Array(filter.data)
        for i in 0..<size {
            let byte = data[i]
            XCTAssertEqual(byte, 0)
        }
    }

    /**
     Verify that a large number of positive matches all are labeled as 'maybe'
     */
    func testPositiveMatches() {
        let size = 1024
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
        let size = 1024 // tiny size to increase the chances of false positives
        let count = 1000
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
        let falsePositiveRate = Double(falsePositives) / Double(count)
        let expFalsePositiveRate = BloomFilter.computeFalsePositiveRate(byteSize: size,
                                                                     elementCount: count)

        XCTAssertTrue(falsePositiveRate < expFalsePositiveRate)
    }

    /**
     Verify that copying the bloom filter's data works properly
     */
    func testCopiedBloomFilter() {
        let size = 1024 * 10
        let count = 10000
        let filter = BloomFilter(size: size, capacity: count)
        var matches = [Data]()

        for _ in 0..<count {
            let match = UUID().uuidString.data(using: .utf8)!
            filter.add(data: match)
            matches.append(match)
        }

        let copiedFilter = BloomFilter(data: filter.data,
                                       capacity: count,
                                       elementCount: filter.elementCount)
        XCTAssertEqual(copiedFilter.elementCount, filter.elementCount)
        XCTAssertEqual(copiedFilter.data.count, filter.data.count)
        XCTAssertEqual(copiedFilter.hashCount, filter.hashCount)
        for match in matches {
            let possibleMatch = copiedFilter.check(data: match)
            XCTAssertTrue(possibleMatch)
            if !possibleMatch {
                break
            }
        }
    }
}
