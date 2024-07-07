//
//  Codable.swift
//  WireMage
//
//  Created by imengX on 8/7/24.
//

import Foundation
import Flow
import SwiftUI

// Codable extension for InputID
extension InputID: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nodeIndex = try container.decode(NodeIndex.self, forKey: .nodeIndex)
        let portIndex = try container.decode(PortIndex.self, forKey: .portIndex)
        self.init(nodeIndex, portIndex)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodeIndex, forKey: .nodeIndex)
        try container.encode(portIndex, forKey: .portIndex)
    }

    private enum CodingKeys: String, CodingKey {
        case nodeIndex
        case portIndex
    }
}

// Codable extension for OutputID
extension OutputID: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nodeIndex = try container.decode(NodeIndex.self, forKey: .nodeIndex)
        let portIndex = try container.decode(PortIndex.self, forKey: .portIndex)
        self.init(nodeIndex, portIndex)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodeIndex, forKey: .nodeIndex)
        try container.encode(portIndex, forKey: .portIndex)
    }

    private enum CodingKeys: String, CodingKey {
        case nodeIndex
        case portIndex
    }
}

// Codable extension for PortType
extension PortType: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let customType = try? container.decode(String.self) {
            self = .custom(customType)
        } else if let type = try? container.decode(Int.self) {
            switch type {
            case 1:
                self = .control
            case 2:
                self = .signal
            case 3:
                self = .midi
            default:
                throw StorageError.value
            }
        } else {
            throw StorageError.value
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .control:
            try container.encode(1)
        case .signal:
            try container.encode(2)
        case .midi:
            try container.encode(3)
        case .custom(let customType):
            try container.encode(customType)
        }
    }
}

// Codable extension for Port
extension Flow.Port: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let type = try container.decode(PortType.self, forKey: .type)
        self.init(name: name, type: type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case type
    }
}

// Codable extension for Node
extension Node: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let position = try container.decode(CGPoint.self, forKey: .position)
        let titleBarColor = try container.decode(Color.self, forKey: .titleBarColor)
        let locked = try container.decode(Bool.self, forKey: .locked)
        let inputs = try container.decode([Flow.Port].self, forKey: .inputs)
        let outputs = try container.decode([Flow.Port].self, forKey: .outputs)

        // Call the original initializer to ensure all properties are initialized
        self.init(name: name, position: position, titleBarColor: titleBarColor, locked: locked, inputs: inputs, outputs: outputs)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(position, forKey: .position)
        try container.encode(titleBarColor, forKey: .titleBarColor)
        try container.encode(locked, forKey: .locked)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(outputs, forKey: .outputs)
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case position
        case titleBarColor
        case locked
        case inputs
        case outputs
    }
}

// Codable extension for Wire
extension Wire: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let output = try container.decode(OutputID.self, forKey: .output)
        let input = try container.decode(InputID.self, forKey: .input)
        self.init(from: output, to: input)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(output, forKey: .output)
        try container.encode(input, forKey: .input)
    }

    private enum CodingKeys: String, CodingKey {
        case output
        case input
    }
}

// Codable extension for Wire
extension Patch: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nodes = try container.decode([Node].self, forKey: .nodes)
        let wires = try container.decode(Set<Wire>.self, forKey: .wires)
        self.init(nodes: nodes, wires: wires)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(wires, forKey: .wires)
    }

    private enum CodingKeys: String, CodingKey {
        case nodes
        case wires
    }
}
