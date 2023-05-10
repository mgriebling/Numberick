//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2022 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

//*============================================================================*
// MARK: * NBK x Double Width Integer x Bits
//*============================================================================*

extension DoubleWidthInteger {
    
    //=------------------------------------------------------------------------=
    // MARK: Accessors
    //=------------------------------------------------------------------------=
    
    @inlinable public static var bitWidth: Int {
        Low.bitWidth + High.bitWidth
    }
    
    //=------------------------------------------------------------------------=
    // MARK: Accessors
    //=------------------------------------------------------------------------=
    
    @inlinable public var nonzeroBitCount: Int {
        self.low.nonzeroBitCount &+ self.high.nonzeroBitCount
    }
    
    @inlinable public var leadingZeroBitCount: Int {
        let count  = self.high.leadingZeroBitCount
        if  count != High.bitWidth { return count }
        return count &+ self.low.leadingZeroBitCount
    }
    
    @inlinable public var trailingZeroBitCount: Int {
        let count  = self.low.trailingZeroBitCount
        if  count != Low.bitWidth { return count }
        return count &+ self.high.trailingZeroBitCount
    }
}
