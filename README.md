# iBloomFilter

Simple Bloom Filter implementation for macOS and iOS.

## Overview

A Bloom Filter is a space compressed data structure for key lookups. 

It is essentially a bitfield representing n objects hashed k times, where each object represents a set of indexes that will be set to 1 within the bitfield.

The number of hashes is determined by the function 

For a full explanation, see: https://en.wikipedia.org/wiki/Bloom_filter

## Usage

This library provides methods for creating an empy bloom filter, adding elements to it, and then checking for elements.

It also provides accessors to the filter's `data`,  `elementCount`, and `capacity`, which can then be serialized and transmitted (or saved as a file). A second initializer exists for recreating an existing filter from data parameters.

Each filter must have a predetermined `capacity` (expected number of elements), and `size` (bytes). These two parameters determine the amount of space the filter should use and the optimal number of hash functions for reducing the false-positive rate for this size/capacity pair.

`elementCount`, while not strictly necessary in serializing a filter, is useful for calculating the expected false-positive rate of the filter. As more elements are added to a filter (whose size is fixed), the false-positive rate increases.

For examples, see `BloomFilterTests.swift`

### xxHash

This implementation uses the `xxHash` function for computing hashes. As of this writing it is one of the fastest algorithms available and far outperforms the expected false-positive rates in testing:
http://cyan4973.github.io/xxHash/

Swift implementation here:
https://github.com/haveahennessy/swift-xxhash




