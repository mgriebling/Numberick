//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2022 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

import Numberick

//*============================================================================*
// MARK: * NBK x 256 x Utilities
//*============================================================================*

extension NBKDoubleWidth {
    
    typealias NBK128X64 = (UInt64, UInt64)
    
    typealias NBK256X64 = (UInt64, UInt64, UInt64, UInt64)
    
    //=------------------------------------------------------------------------=
    // MARK: Initializers
    //=------------------------------------------------------------------------=
    
    init(x64: NBK256X64) where BitPattern == UInt128 {
        #if _endian(big)
        self = unsafeBitCast((x64.1, x64.0), to: Self.self)
        #else
        self = unsafeBitCast((x64), to: Self.self)
        #endif
    }
    
    init(x64: NBK256X64) where BitPattern == UInt256 {
        #if _endian(big)
        self = unsafeBitCast((x64.3, x64.2, x64.1, x64.0), to: Self.self)
        #else
        self = unsafeBitCast((x64), to: Self.self)
        #endif
    }
}
