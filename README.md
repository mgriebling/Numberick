# Numberick

Large number arithmetic in Swift.

| Package | Swift | iOS  | iPadOS | Mac Catalyst | macOS | tvOS | watchOS |
|:-------:|:-----:|:----:|:------:|:------------:|:-----:|:----:|:-------:|
| 1.0.0   | 5.8   | 16.4 | 16.4   | 16.4         | 13.3  | 16.4 | 9.4     |

## NBKCoreKit ([Sources][COR/S], [Tests][COR/T], [Benchmarks][COR/B])

Models, protocols, and extensions underpinning this package.

### Protocols

- [NBKBinaryInteger](Sources/NBKCoreKit/NBKBinaryInteger.swift)
- [NBKBitPatternConvertible](Sources/NBKCoreKit/NBKBitPatternConvertible.swift)
- [NBKCoreInteger](Sources/NBKCoreKit/NBKCoreInteger.swift)
- [NBKFixedWidthInteger](Sources/NBKCoreKit/NBKFixedWidthInteger.swift)
- [NBKMachineWordsInteger](Sources/NBKCoreKit/NBKMachineWordsInteger.swift)
- [NBKRadixStringConvertible](Sources/NBKCoreKit/NBKRadixStringConvertible.swift)
- [NBKSignedInteger](Sources/NBKCoreKit/NBKBinaryInteger.swift)
- [NBKUnsignedInteger](Sources/NBKCoreKit/NBKBinaryInteger.swift)

## NBKDoubleWidthKit ([Sources][DBL/S], [Tests][DBL/T], [Benchmarks][DBL/B])

A composable, large, fixed-width, two's complement, binary integer.

<table>
<tr><td>:jigsaw:</td><td>Composable</td></tr>
<tr><td>:two_hearts:</td><td>Two's Complement</td></tr>
<tr><td>:european_castle:</td><td>Fixed Width Integer</td></tr>
<tr><td>:book:</td><td>Trivial UInt Collection</td></tr>
<tr><td>:rocket:</td><td>Single Digit Arithmetic</td></tr>
</table>

```swift
typealias  Int256 = NBKDoubleWidth< Int128>
typealias UInt256 = NBKDoubleWidth<UInt128>
```

<!-- Links -->

[COR/S]: Sources/NBKCoreKit
[DBL/S]: Sources/NBKDoubleWidthKit

[COR/T]: Tests/NBKCoreKitTests
[DBL/T]: Tests/NBKDoubleWidthKitTests

[COR/B]: Tests/NBKCoreKitBenchmarks
[DBL/B]: Tests/NBKDoubleWidthKitBenchmarks
