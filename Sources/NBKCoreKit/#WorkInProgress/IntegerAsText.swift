//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2023 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

//*============================================================================*
// MARK: * NBK x Integer As Text x Encode
//*============================================================================*

extension String {
    
    //=------------------------------------------------------------------------=
    // MARK: Utilities
    //=------------------------------------------------------------------------=
    
    @inlinable public init(encoding integer: some NBKBinaryInteger, radix: Int = 10, uppercase: Bool = false) {
        self.init(integer, radix: radix, uppercase: uppercase)
    }
}
