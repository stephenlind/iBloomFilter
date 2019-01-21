import Foundation

/**
 Top-level protocol for bloom filter objects, which will be customized by algorithm
 and input types.
 */
protocol BloomFilterProtocol {

    /**
     Create a new empty filter with a given size (in bytes)
     - parameter size: fixed size of the filter, in bytes.
     - parameter capacity: expected total number of elements which will be added
        (this is used for optimizing the number of hash functions)
     */
    init(size: Int, capacity: Int)
    
    /**
     Re-create an existing bloom filter with populated values
     - parameter data: bitfield as binary data
     - parameter capacity: The capacity this bloom filter was created with (determines hash count)
     - parameter elementCount: the number of elements that have been added so far
     
     Given a previously created bloom filter, this method allows you to re-create
     it given parameters that could be saved or transmitted as serialized data.
     */
    init(data: Data, capacity: Int, elementCount: Int)

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

    /**
     The number of hash functions used in this filter
     (for serializing and copying)
     */
    var hashCount: Int { get }
    
    /**
     Bitfield as binary data
     (for serializing and copying)
     */
    var data: Data { get }

}
