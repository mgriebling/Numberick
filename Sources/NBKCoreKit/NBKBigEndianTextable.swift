//=----------------------------------------------------------------------------=
// This source file is part of the Numberick open source project.
//
// Copyright (c) 2023 Oscar Byström Ericsson
// Licensed under Apache License, Version 2.0
//
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
//=----------------------------------------------------------------------------=

//*============================================================================*
// MARK: * NBK x Big Endian Textable
//*============================================================================*

/// An integer type than can be converted to and from big-endian text.
///
/// - `Decode` big-endian text with ``init(decoding:radix:)``.
/// - `Encode` big-endian text with `String.init(encoding:radix:uppercase:)`.
///
public protocol NBKBigEndianTextable {
    
    //=------------------------------------------------------------------------=
    // MARK: Utilities
    //=------------------------------------------------------------------------=
    
    /// Creates a new instance from the given string and optional radix.
    ///
    /// If the given radix is `nil`, it is either decoded from the string or assigned the value `10`.
    ///
    @inlinable static func decodeBigEndianText(_ source: some StringProtocol,  radix: Int?) -> Self?
    
    /// Creates a string representing the given value, using the given format.
    @inlinable static func encodeBigEndianText(_ source: Self, radix: Int, uppercase: Bool) -> String
}

//=----------------------------------------------------------------------------=
// MARK: + Details x Decode
//=----------------------------------------------------------------------------=

extension NBKBigEndianTextable {
    
    //=------------------------------------------------------------------------=
    // MARK: Initializers
    //=------------------------------------------------------------------------=
    
    /// Creates a new instance from the given string and optional radix.
    ///
    /// If the given radix is `nil`, it is either decoded from the string or assigned the value `10`.
    ///
    @inlinable public init?(decoding source: some StringProtocol, radix: Int? = nil) {
        if let value = Self.decodeBigEndianText(source, radix: radix) { self = value } else { return nil }
    }
}

//=----------------------------------------------------------------------------=
// MARK: + Details x Encode
//=----------------------------------------------------------------------------=

extension String {
    
    //=------------------------------------------------------------------------=
    // MARK: Initializers
    //=------------------------------------------------------------------------=
    
    /// Creates a string representing the given value, using the given format.
    @inlinable public init(encoding source: some NBKBigEndianTextable, radix: Int = 10, uppercase: Bool = false) {
        self = type(of: source).encodeBigEndianText(source, radix: radix, uppercase: uppercase)
    }
}
