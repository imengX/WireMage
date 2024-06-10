//
//  SignalConvertNode.swift
//  WireMage
//
//  Created by imengX on 10/6/24.
//

import Foundation

class SignalConvertNode: ProcessingBasicNode, FlowNodePortProtocol {
    lazy var outputs: [FlowPort] = [signalValuePort]
    lazy var inputs: [FlowPort] = [floatPort, boolPort]

    let floatPort = FlowPort(name: "floatPort", type: .floatValue)
    let boolPort = FlowPort(name: "boolPort", type: .boolValue)
    let signalValuePort = FlowPort(name: "value", type: .signal)

//    func handlePackage(pipelinePackage: PipelinePackage) async {
//        let port = inputs[pipelinePackage.wire.input.portIndex]

//    }
}
