//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2023 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

import NBKCoreKit

//*============================================================================*
// MARK: * NBK x Double Width x Text x Radix
//*============================================================================*
//=----------------------------------------------------------------------------=
// MARK: + Unsigned
//=----------------------------------------------------------------------------=

extension NBKDoubleWidth where High == High.Magnitude {
    
    //=------------------------------------------------------------------------=
    // MARK: Details x Decode
    //=------------------------------------------------------------------------=
    
    @inlinable public init?(digits: UnsafeBufferPointer<UInt8>, radix: Int) {
        self.init(digits: digits, radix: AnyRadixUIntRoot(radix))
    }
    
    @inlinable internal init?(digits: UnsafeBufferPointer<UInt8>, radix: AnyRadixUIntRoot) {
        switch radix.power.isZero {
        case  true: self.init(digits: digits, radix:   PerfectRadixUIntRoot(unchecked: radix))
        case false: self.init(digits: digits, radix: ImperfectRadixUIntRoot(unchecked: radix)) }
    }
    
    @inlinable internal init?(digits: UnsafeBufferPointer<UInt8>, radix: PerfectRadixUIntRoot) {
        var digits = digits.drop(while:{ $0 == 48 })
        //=--------------------------------------=
        self.init()
        var index: Int = self.startIndex
        
        backwards: while !digits.isEmpty {
            guard index < self.endIndex else { return nil }
            let chunk = digits.suffix(radix.exponent)
            digits    = digits.prefix(upTo: chunk.startIndex)
            
            guard let word = UInt(digits: UnsafeBufferPointer(rebasing: chunk), radix: radix.base) else { return nil }

            self[index] = word
            self.formIndex(after: &index)
        }
    }
    
    @inlinable internal init?(digits: UnsafeBufferPointer<UInt8>, radix: ImperfectRadixUIntRoot) {
        var digits = digits.drop(while:{ $0 == 48 })
        let alignment = digits.count % radix.exponent
        //=--------------------------------------=
        self.init()
        
        forwards: if !alignment.isZero {
            let chunkEndIndex = digits.startIndex &+ alignment
            let chunk = digits.prefix(upTo: chunkEndIndex)
            digits    = digits.suffix(from: chunkEndIndex)
            
            guard let word = UInt(digits: UnsafeBufferPointer(rebasing: chunk), radix: radix.base) else { return nil }
            self.first = word // self = (self * radix.power) + word, because self == 0
        }
        
        forwards: while !digits.isEmpty {
            let chunkEndIndex = digits.startIndex &+ radix.exponent
            let chunk = digits.prefix(upTo: chunkEndIndex)
            digits    = digits.suffix(from: chunkEndIndex)

            guard let word = UInt(digits: UnsafeBufferPointer(rebasing: chunk), radix: radix.base) else { return nil }
            guard !self.multiplyReportingOverflow(by: radix.power) else { return nil }
            guard !self.addReportingOverflow(word)/*------------*/ else { return nil }
        }
    }
    
    //=------------------------------------------------------------------------=
    // MARK: Details x Encode
    //=------------------------------------------------------------------------=
    
    @inlinable public func description(radix: Int, uppercase: Bool, minus: Bool) -> String {
        self.description(radix: AnyRadixUIntRoot(radix), alphabet: MaxRadixAlphabet(uppercase: uppercase), minus: minus)
    }
    
    @inlinable internal func description(radix: AnyRadixUIntRoot, alphabet: MaxRadixAlphabet, minus: Bool) -> String {
        switch radix.power.isZero {
        case  true: return self.description(radix:   PerfectRadixUIntRoot(unchecked: radix), alphabet: alphabet, minus: minus)
        case false: return self.description(radix: ImperfectRadixUIntRoot(unchecked: radix), alphabet: alphabet, minus: minus) }
    }
    
    @inlinable internal func description(radix: PerfectRadixUIntRoot, alphabet: MaxRadixAlphabet, minus: Bool) -> String {
        let minLastIndex: Int = self.minLastIndexReportingIsZeroOrMinusOne().minLastIndex
        return String(chunks: self[...minLastIndex], radix: radix, alphabet: alphabet, minus: minus)
    }
    
    @inlinable internal func description(radix: ImperfectRadixUIntRoot, alphabet: MaxRadixAlphabet, minus: Bool) -> String {
        let capacity: Int = radix.divisibilityByPowerUpperBound(self)
        return withUnsafeTemporaryAllocation(of: UInt.self, capacity: capacity) { chunks in
            var magnitude = self
            var index = chunks.startIndex
            
            rebasing: repeat {
                let (remainder, overflow) = magnitude.formQuotientReportingRemainderAndOverflow(dividingBy: radix.power)
                chunks[index] = remainder
                chunks.formIndex(after: &index)
                assert(!overflow)
            }   while !magnitude.isZero
            
            return String(chunks: chunks[..<index], radix: radix, alphabet: alphabet, minus: minus)
        }
    }
}

//=----------------------------------------------------------------------------=
// MARK: + String
//=----------------------------------------------------------------------------=

extension String {
    
    //=------------------------------------------------------------------------=
    // MARK: Initializers
    //=------------------------------------------------------------------------=
    
    @inlinable internal init(chunks: some RandomAccessCollection<UInt>, radix: some RadixUIntRoot, alphabet: MaxRadixAlphabet, minus: Bool) {
        assert(chunks.last! != 0 || chunks.count == 1)
        assert(chunks.allSatisfy({ $0 < radix.power }) || radix.power.isZero)
        //=--------------------------------------=
        self = Self.withUTF8(chunk: chunks.last!, radix: radix, alphabet: alphabet) { first in
            let count = Int(bit: minus) &+ first.count + radix.exponent * (chunks.count &- 1)
            return Self(unsafeUninitializedCapacity: count) { utf8 in
                var index = utf8.startIndex
                //=------------------------------=
                if  minus {
                    utf8.initializeElement(at: index, to: 45)
                    index =  utf8.index(after: index)
                }
                //=------------------------------=
                index = utf8[index...].initialize(fromContentsOf: first)
                //=------------------------------=
                for var chunk in chunks.dropLast().reversed() {
                    let destination = utf8.index(index, offsetBy: radix.exponent)
                    var backtrack = destination
                    defer { index = destination }
                    
                    backwards: while backtrack > index {
                        utf8.formIndex(before: &backtrack)
                        
                        let digit: UInt
                        (chunk,  digit) = radix.dividing(chunk)
                        let unit: UInt8 = alphabet[unchecked: UInt8(_truncatingBits: digit)]
                        utf8.initializeElement(at: backtrack, to: unit)
                    }
                }
                //=------------------------------=
                assert(utf8[..<index].count == count)
                return count
            }
        }
    }
    
    @inlinable internal static func withUTF8<T>(chunk: UInt, radix: some RadixUIntRoot, alphabet: MaxRadixAlphabet,
    body: (UnsafeBufferPointer<UInt8>) throws -> T) rethrows -> T {
        try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: radix.exponent) { utf8 in
            assert(chunk < radix.power || radix.power.isZero)
            //=----------------------------------=
            var chunk = chunk as UInt
            var backtrack = radix.exponent as Int
            //=----------------------------------=
            backwards: repeat {
                utf8.formIndex(before: &backtrack)
                
                let digit: UInt
                (chunk,  digit) = radix.dividing(chunk)
                let unit: UInt8 = alphabet[unchecked: UInt8(_truncatingBits: digit)]
                utf8.initializeElement(at: backtrack, to: unit)
            }   while !chunk.isZero
            //=----------------------------------=
            let initialized = utf8[backtrack...]
            defer { initialized.deinitialize() }
            //=----------------------------------=
            return try body(UnsafeBufferPointer(rebasing: initialized))
        }
    }
}
