//
//  Color.Extension.swift
//  WireMage
//
//  Created by imengX on 8/7/24.
//

import SwiftUI
import SwifterSwift

extension Color: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let data = try container.decode(String.self)
        guard let platformColor = PlatformColor(argbHexString: data)
        else {
            throw DecodingError.wrongType
        }
        self.init(platformColor: platformColor)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let platformColor = PlatformColor(self)
        let data = platformColor.hexString
        try container.encode(data)
    }
}

#if os(iOS)
typealias PlatformColor = UIColor
extension Color {
    init(platformColor: PlatformColor) {
        self.init(uiColor: platformColor)
    }
}
#elseif os(macOS)
typealias PlatformColor = NSColor
extension Color {
    init(platformColor: PlatformColor) {
        self.init(nsColor: platformColor)
    }
}
#endif

enum DecodingError: Error {
    case wrongType
}
