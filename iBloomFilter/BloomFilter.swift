import Foundation

/**
 Top-level protocol for bloom filter objects, which will be customized by algorithm
 and input types.
 */
protocol BloomFilter {

    /**
     Create a new empty filter with a given size (in bytes)
     - parameter size: fixed size of the filter, in bytes.
     - parameter capacity: expected total number of elements which will be added
        (this is used for optimizing the number of hash functions)
     */
    init(size: Int, capacity: Int)

    /**
     Check the filter for a piece of data to see if it is a possible match.
     - Parameter data: Data (key) to check
     - Returns: Yes if the data is possibly a match.
        No if it is *definitely* not a match.
     */
    func check(data: Data) -> Bool

    /**
     Add an item as a positive match
     - parameter data: Data to checksum and add to the filter
     */
    func add(data: Data)

    /**
     The number of elements that have been added to this bloom filter
     */
    var elementCount: Int { get }

}
