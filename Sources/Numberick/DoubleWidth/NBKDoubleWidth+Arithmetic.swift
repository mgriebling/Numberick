//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2022 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

//*============================================================================*
// MARK: * NBK x Double Width x Arithmetic
//*============================================================================*

extension NBKDoubleWidth {
    
    //=------------------------------------------------------------------------=
    // MARK: Utilities
    //=------------------------------------------------------------------------=
    
    /// The modulus of dividing this value by its bit width.
    ///
    /// - Returns: `abs(self % Self.bitWidth)`
    ///
    @inlinable public var moduloBitWidth: Int {
        Int(bitPattern: self._lowWord) & (Self.bitWidth &- 1)
    }
}