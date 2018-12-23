import Foundation

/**
 Top-level protocol for bloom filter objects, which will be customized by algorithm
 and input types.
 */
protocol BloomFilter {

    // MARK: Public

    /**
     Create a new empty filter with a given size (in bytes)
     - parameter size: fixed size of the filter, in bytes.
     */
    init(size: Int)

    /**
     Create a filter with existing byte filter
     - parameter data: filter data, computed previously
     */
    init(data: Data)

    /**
     Check the filter for a piece of data to see if it is a possible match.
     - Parameter data: Data (key) to check
     - Returns: Yes if the data is possibly a match.
        No if it is *definitely* not a match.
     */
    func checkMatch(data: Data) -> Bool

    /**
     Add an item as a positive match
     - parameter data: Data to checksum and add to the filter
     */
    func addMatch(data: Data)

    /**
     Get or set the raw filter data.
     Bloom filter data is a single bitmap.
     This data is only valid for filters of the same size, using the same
     checksum algorithm.
     */
    var filterData: Data { get set }

    // MARK: Private

    /**
     Compute a checksum for a given piece of data
     - Parameter data: Data to checksum
     - Returns: Checksum as an integer. If this integer is larger than your bloom filter size, the modulus will be taken for its checksum.
     */
    func computeChecksum(data: Data) -> Int64

}
