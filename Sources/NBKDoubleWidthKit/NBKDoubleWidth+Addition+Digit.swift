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
// MARK: * NBK x Double Width x Addition x Digit
//*============================================================================*

extension NBKDoubleWidth {
    
    //=------------------------------------------------------------------------=
    // MARK: Transformations
    //=------------------------------------------------------------------------=
    
    @_disfavoredOverload @inlinable public mutating func addReportingOverflow(_ amount: Digit) -> Bool {
        self.withUnsafeMutableWords { words in
            let amountIsLessThanZero: Bool = amount.isLessThanZero
            var carry: Bool = words.first.addReportingOverflow(UInt(bitPattern: amount))
            //=----------------------------------=
            if  carry == amountIsLessThanZero { return false }
            let extra =  UInt(bitPattern: amountIsLessThanZero ? -1 : 1)
            //=----------------------------------=
            for index in 1 ..< words.lastIndex {
                carry =  words[index].addReportingOverflow(extra)
                if carry == amountIsLessThanZero { return false }
            }
            //=----------------------------------=
            let pvo: PVO<Digit> = Digit(bitPattern: words.last).addingReportingOverflow(Digit(bitPattern: extra))
            words.last = UInt(bitPattern: pvo.partialValue)
            return pvo.overflow as Bool
        }
    }
    
    @_disfavoredOverload @inlinable public func addingReportingOverflow(_ amount: Digit) -> PVO<Self> {
        var partialValue = self
        let overflow: Bool = partialValue.addReportingOverflow(amount)
        return PVO(partialValue, overflow)
    }
}

