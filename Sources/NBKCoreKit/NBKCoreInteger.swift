//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2023 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

//*============================================================================*
// MARK: * NBK x Core Integer
//*============================================================================*

/// A fixed-width, binary, integer.
///
/// Only the following types in the standard library may conform to this protocol:
///
/// - `Int`
/// - `Int8`
/// - `Int16`
/// - `Int32`
/// - `Int64`
///
/// - `UInt`
/// - `UInt8`
/// - `UInt16`
/// - `UInt32`
/// - `UInt64`
///
public protocol NBKCoreInteger<Magnitude>: NBKFixedWidthInteger where
BitPattern == Magnitude, Digit == Self, Magnitude: NBKCoreInteger { }

//=----------------------------------------------------------------------------=
// MARK: + Details
//=----------------------------------------------------------------------------=

extension NBKCoreInteger {
    
    //=------------------------------------------------------------------------=
    // MARK: Details x Bit Pattern
    //=------------------------------------------------------------------------=
    
    @inlinable public init(bitPattern: BitPattern) {
        self = Swift.unsafeBitCast(bitPattern, to: Self.self)
    }
    
    @inlinable public var bitPattern: BitPattern {
        Swift.unsafeBitCast(self, to: BitPattern.self)
    }
    
    //=------------------------------------------------------------------------=
    // MARK: Details x Two's Complement
    //=------------------------------------------------------------------------=
    
    @inlinable public mutating func formTwosComplementSubsequence(_ carry: Bool) -> Bool {
        let pvo: PVO<Self> = self.twosComplementSubsequence(carry)
        self = pvo.partialValue
        return pvo.overflow as Bool
    }
    
    @inlinable public func twosComplementSubsequence(_ carry: Bool) -> PVO<Self> {
        var partialValue = ~self
        let overflow: Bool = carry && partialValue.addReportingOverflow(1 as Self)
        return PVO(partialValue, overflow)        
    }
    
    //=------------------------------------------------------------------------=
    // MARK: Details x Addition, Subtraction, Multiplication, Division
    //=------------------------------------------------------------------------=
    
    @inlinable public mutating func addReportingOverflow(_ other: Self) -> Bool {
        let pvo: PVO<Self> = self.addingReportingOverflow(other)
        self = pvo.partialValue
        return pvo.overflow as Bool
    }
    
    @inlinable public mutating func subtractReportingOverflow(_ other: Self) -> Bool {
        let pvo: PVO<Self> = self.subtractingReportingOverflow(other)
        self = pvo.partialValue
        return pvo.overflow as Bool
    }
    
    @inlinable public mutating func multiplyReportingOverflow(by other: Self) -> Bool {
        let pvo: PVO<Self> = self.multipliedReportingOverflow(by: other)
        self = pvo.partialValue
        return pvo.overflow as Bool
    }
    
    @inlinable public mutating func multiplyFullWidth(by other: Self) -> Self {
        let product: HL<Self, Magnitude> = self.multipliedFullWidth(by: other)
        self = Self(bitPattern: product.low)
        return product.high as Self
    }
    
    @inlinable public mutating func divideReportingOverflow(by other: Self) -> Bool {
        let pvo: PVO<Self> = self.dividedReportingOverflow(by: other)
        self = pvo.partialValue
        return pvo.overflow as Bool
    }
    
    @inlinable public mutating func formRemainderReportingOverflow(dividingBy other: Self) -> Bool {
        let pvo: PVO<Self> = self.remainderReportingOverflow(dividingBy: other)
        self = pvo.partialValue
        return pvo.overflow as Bool
    }
    
    @inlinable public func quotientAndRemainder(dividingBy other: Self) -> QR<Self, Self> {
        let qro: PVO<QR<Self, Self>> = self.quotientAndRemainderReportingOverflow(dividingBy: other)
        precondition(!qro.overflow, NBK.callsiteOverflowInfo())
        return qro.partialValue as QR<Self, Self>
    }
    
    @inlinable public func quotientAndRemainderReportingOverflow(dividingBy other: Self) -> PVO<QR<Self, Self>> {
        let quotient:  PVO<Self> = self.dividedReportingOverflow(by: other)
        let remainder: PVO<Self> = self.remainderReportingOverflow(dividingBy: other)
        assert(quotient.overflow == remainder.overflow)
        return PVO(QR(quotient.partialValue, remainder.partialValue), quotient.overflow)
    }
    
    @inlinable public func dividingFullWidthReportingOverflow(_ other: HL<Self, Magnitude>) -> PVO<QR<Self, Self>> {
        //=--------------------------------------=
        if  self.isZero {
            return PVO(QR(Self(bitPattern: other.low), Self(bitPattern: other.low)), true)
        }
        //=--------------------------------------=
        let lhsIsLessThanZero: Bool = other.high.isLessThanZero
        let rhsIsLessThanZero: Bool = /*-----*/self.isLessThanZero
        let minus: Bool  = (lhsIsLessThanZero != rhsIsLessThanZero)
        //=--------------------------------------=
        var lhsMagnitude = HL(Magnitude(bitPattern: other.high), other.low)
        if  lhsIsLessThanZero {
            var carry = true
            carry = lhsMagnitude.low .formTwosComplementSubsequence(carry)
            carry = lhsMagnitude.high.formTwosComplementSubsequence(carry)
        }
        
        let rhsMagnitude = self.magnitude as Magnitude
        //=--------------------------------------=
        var qro = PVO(rhsMagnitude.dividingFullWidth(lhsMagnitude), lhsMagnitude.high >= rhsMagnitude)
        //=--------------------------------------=
        if  minus {
            qro.partialValue.quotient.formTwosComplement()
        }

        if  lhsIsLessThanZero {
            qro.partialValue.remainder.formTwosComplement()
        }
        
        if  Self.isSigned, qro.partialValue.quotient.mostSignificantBit != minus {
            qro.overflow = minus ? (qro.overflow || !qro.partialValue.quotient.isZero) : true
        }
        //=--------------------------------------=
        return PVO(QR(Self(bitPattern: qro.partialValue.quotient), Self(bitPattern: qro.partialValue.remainder)), qro.overflow)
    }
}

//*============================================================================*
// MARK: * NBK x Core Integer x Swift
//*============================================================================*

extension Int: NBKCoreInteger, NBKSignedInteger {    
    public typealias BitPattern = Magnitude
}

extension Int8: NBKCoreInteger, NBKSignedInteger {
    public typealias BitPattern = Magnitude
}

extension Int16: NBKCoreInteger, NBKSignedInteger {
    public typealias BitPattern = Magnitude
}

extension Int32: NBKCoreInteger, NBKSignedInteger {
    public typealias BitPattern = Magnitude
}

extension Int64: NBKCoreInteger, NBKSignedInteger {
    public typealias BitPattern = Magnitude
}

extension UInt: NBKCoreInteger, NBKUnsignedInteger {
    public typealias BitPattern = Magnitude
}

extension UInt8: NBKCoreInteger, NBKUnsignedInteger {
    public typealias BitPattern = Magnitude
}

extension UInt16: NBKCoreInteger, NBKUnsignedInteger {
    public typealias BitPattern = Magnitude
}

extension UInt32: NBKCoreInteger, NBKUnsignedInteger {
    public typealias BitPattern = Magnitude
}

extension UInt64: NBKCoreInteger, NBKUnsignedInteger {
    public typealias BitPattern = Magnitude
}
