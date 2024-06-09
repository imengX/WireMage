//
//  Define.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation
import Flow

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
    static let floatValue = FlowPortType.custom("FloatValue")
    static let intValue = FlowPortType.custom("IntValue")
    static let any = FlowPortType.custom("Any")
}
