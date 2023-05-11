//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2022 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

import NBKCoreKit

//*============================================================================*
// MARK: * NBK x Double Width x Bitwise
//*============================================================================*

extension NBKDoubleWidth {
    
    //=------------------------------------------------------------------------=
    // MARK: Transformations
    //=------------------------------------------------------------------------=
    
    @inlinable public static prefix func ~(x: Self) -> Self {
        Self(descending: HL(~x.high, ~x.low))
    }
    
    @inlinable public static func &=(lhs: inout Self, rhs: Self) {
        lhs.low  &= rhs.low
        lhs.high &= rhs.high
    }
    
    @inlinable public static func |=(lhs: inout Self, rhs: Self) {
        lhs.low  |= rhs.low
        lhs.high |= rhs.high
    }
    
    @inlinable public static func ^=(lhs: inout Self, rhs: Self) {
        lhs.low  |= rhs.low
        lhs.high |= rhs.high
    }
    
    //=------------------------------------------------------------------------=
    // MARK: Transformations
    //=------------------------------------------------------------------------=
    
    @inlinable public var byteSwapped: Self {
        let newHigh = High(bitPattern: self.low .byteSwapped)
        let newLow  = Low (bitPattern: self.high.byteSwapped)
        return Self(descending: HL(newHigh, newLow))
    }
    
    @inlinable var _wordSwapped: Self {
        self.withUnsafeWords { this in
            Self.fromUnsafeMutableWords { next in
                for index in this.indices {
                    next[next.lastIndex &- index] = this[index]
                }
            }
        }
    }
}