//
//  Define.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation
import Flow
import SwiftUI

typealias FlowOutputID = Flow.OutputID
typealias FlowInputID = Flow.InputID
typealias FlowNodeIndex = Flow.NodeIndex
typealias FlowNode = Flow.Node
typealias FlowWire = Flow.Wire
typealias FlowPort = Flow.Port
typealias FlowPortType = Flow.PortType
typealias FlowPatch = Flow.Patch


protocol FlowNodePortProtocol {
    var inputs: [FlowPort] { get }
    var outputs: [FlowPort] { get }
}

protocol FlowNodePortDefineProtocol {
    static var inputs: [FlowPort] { get }
    static var outputs: [FlowPort] { get }
}

extension FlowNodePortDefineProtocol {
    static var inputs: [FlowPort] { [] }
    static var outputs: [FlowPort] { [] }
}

protocol FlowNodeDescript {

}

extension FlowPortType {
    static let polarValue = FlowPortType.custom("PolarValue")
    static let vectorValue = FlowPortType.custom("VectorValue")
    static let floatValue = FlowPortType.custom("FloatValue")
    static let intValue = FlowPortType.custom("IntValue")
    static let boolValue = FlowPortType.custom("boolValue")
}

extension FlowPortType {
    var dataType: Any.Type? {
        switch self {
        case .control:
            return Any.self
        case .signal:
            return Any.self
        case .midi:
            return Any.self
        case .custom(let string):
            switch self {
            case .polarValue:
                return PolarValue.self
            case .vectorValue:
                return VectorValue.self
            case .floatValue:
                return Float.self
            case .intValue:
                return Int.self
            case .boolValue:
                return Bool.self
            default:
                return nil
            }
        }
    }
}

struct PolarValue {
    var radius: Float, angle: Angle
}

struct VectorValue {
    var x: Float, y: Float
}
