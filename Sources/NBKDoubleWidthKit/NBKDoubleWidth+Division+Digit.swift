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
// MARK: * NBK x Double Width x Division x Digit
//*============================================================================*

extension NBKDoubleWidth {
    
    //=------------------------------------------------------------------------=
    // MARK: Transformations
    //=------------------------------------------------------------------------=
    
    @_disfavoredOverload @_transparent public mutating func divideReportingOverflow(by divisor: Digit) -> Bool {
        let pvo: PVO<Self> = self.dividedReportingOverflow(by: divisor)
        self = pvo.partialValue
        return pvo.overflow as Bool
    }
    
    @_disfavoredOverload @_transparent public func dividedReportingOverflow(by divisor: Digit) -> PVO<Self> {
        let qro: PVO<QR<Self, Digit>> = self.quotientAndRemainderReportingOverflow(dividingBy: divisor)
        return   PVO(qro.partialValue.quotient, qro.overflow)
    }
    
    @_disfavoredOverload @_transparent public mutating func formRemainderReportingOverflow(dividingBy divisor: Digit) -> Bool {
        let pvo: PVO<Digit> = self.remainderReportingOverflow(dividingBy: divisor)
        self = Self(digit: pvo.partialValue)
        return pvo.overflow as Bool
    }
    
    @_disfavoredOverload @_transparent public func remainderReportingOverflow(dividingBy divisor: Digit) -> PVO<Digit> {
        let qro: PVO<QR<Self, Digit>> = self.quotientAndRemainderReportingOverflow(dividingBy: divisor)
        return   PVO(qro.partialValue.remainder, qro.overflow)
    }
    
    @_disfavoredOverload @inlinable public func quotientAndRemainderReportingOverflow(dividingBy divisor: Digit) -> PVO<QR<Self, Digit>> {
        let dividendIsLessThanZero: Bool =    self.isLessThanZero
        let  divisorIsLessThanZero: Bool = divisor.isLessThanZero
        //=--------------------------------------=
        let qro_ = self.magnitude.quotientAndRemainderReportingOverflow(dividingBy: divisor.magnitude)
        var qro  = PVO(QR(Self(bitPattern: qro_.partialValue.quotient), Digit(bitPattern: qro_.partialValue.remainder)), qro_.overflow)
        //=--------------------------------------=
        if  qro.overflow {
            assert(divisor.isZero)
            assert(qro.partialValue.quotient  == self)
            assert(qro.partialValue.remainder == Digit())
            return qro
        }

        if  dividendIsLessThanZero != divisorIsLessThanZero {
            qro.partialValue.quotient.formTwosComplement()
        }
        
        if  dividendIsLessThanZero && divisorIsLessThanZero && qro.partialValue.quotient.isLessThanZero {
            assert(Self.isSigned && self == Self.min && divisor == -1)
            assert(qro.partialValue.quotient  == self)
            assert(qro.partialValue.remainder == Digit())
            qro.overflow = true
            return qro
        }
        
        if  dividendIsLessThanZero {
            qro.partialValue.remainder.formTwosComplement()
        }
        //=--------------------------------------=
        return qro as PVO<QR<Self, Digit>>
    }
}

//=----------------------------------------------------------------------------=
// MARK: + Unsigned
//=----------------------------------------------------------------------------=

extension NBKDoubleWidth where High == High.Magnitude {
    
    //=------------------------------------------------------------------------=
    // MARK: Transformations
    //=------------------------------------------------------------------------=
    
    @_disfavoredOverload @inlinable public func quotientAndRemainderReportingOverflow(dividingBy divisor: Digit) -> PVO<QR<Self, Digit>> {
        var quotient  = self
        let remainder = quotient._formQuotientReportingRemainderAndOverflow(dividingBy: divisor)
        return PVO(QR(quotient, remainder.partialValue), remainder.overflow)
    }
    
    @inlinable mutating func _formQuotientReportingRemainderAndOverflow(dividingBy divisor: Digit) -> PVO<Digit> {
        //=--------------------------------------=
        if  divisor.isZero {
            return PVO(UInt(), true)
        }
        //=--------------------------------------=
        var remainder = UInt()
        
        self.withUnsafeMutableWords { words in
            var index: Int = words.endIndex
            backwards: while index != words.startIndex {
                (words.formIndex(before: &index))
                (words[index], remainder) = divisor.dividingFullWidth(HL(remainder, words[index]))
            }
        }
        
        return PVO(remainder, false)
    }
}