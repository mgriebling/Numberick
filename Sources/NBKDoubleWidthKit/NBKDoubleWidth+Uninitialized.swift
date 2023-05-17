//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2023 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

//*============================================================================*
// MARK: * NBK x Double Width x Uninitialized
//*============================================================================*

extension NBKDoubleWidth {
    
    //=------------------------------------------------------------------------=
    // MARK: Initializers
    //=------------------------------------------------------------------------=
    
    @inlinable public static func uninitialized(_ body: (inout Self) -> Void) -> Self {
         withUnsafeTemporaryAllocation(of: Self.self, capacity: 1) {
            body( &$0.baseAddress.unsafelyUnwrapped.pointee)
            return($0.baseAddress.unsafelyUnwrapped.pointee)
        }
    }
}
