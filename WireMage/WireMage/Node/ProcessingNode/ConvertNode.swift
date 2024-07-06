//
//  ConvertNode.swift
//  WireMage
//
//  Created by imengX on 10/6/24.
//

import Foundation

class SignalConvertNode: ProcessingBasicNode, FlowNodePortProtocol {
    lazy var outputs: [FlowPort] = [signalValuePort]
    lazy var inputs: [FlowPort] = [floatPort, boolPort]

    let floatPort = FlowPort(name: "floatPort\n(value>0)", type: .floatValue)
    let boolPort = FlowPort(name: "boolPort\n(true)", type: .boolValue)
    let signalValuePort = FlowPort(name: "signal", type: .signal)

    override func handlePackage(pipelinePackage: PipelinePackage) async {
        let input = pipelinePackage.wire.input
        let outputID = FlowOutputID(input.nodeIndex, 0)

        var signal: Bool? = nil
        let port = inputs[input.portIndex]
        switch port {
        case floatPort:
            if let data = pipelinePackage.data as? Float {
                signal = data > 0
            }
        case boolPort:
            if let data = pipelinePackage.data as? Bool {
                signal = data
            }
        default: break

        }
        guard signal == true else {
            return
        }
        do {
            try await dispatcher?.dispatch(data: pipelinePackage.data, to: outputID)
        } catch {
            print(error)
        }
    }
}

class BoolConvertNode: ProcessingBasicNode, FlowNodePortProtocol {

    lazy var outputs: [FlowPort] = [truePort, falsePort]
    lazy var inputs: [FlowPort] = [floatPort, boolPort]

    let floatPort = FlowPort(name: "floatPort", type: .floatValue)
    let boolPort = FlowPort(name: "boolPort", type: .boolValue)

    let truePort = FlowPort(name: "trueSignal", type: .signal)
    let falsePort = FlowPort(name: "falseSignal", type: .signal)

    override func handlePackage(pipelinePackage: PipelinePackage) async {
        let input = pipelinePackage.wire.input

        var signal: Bool? = nil
        let port = inputs[input.portIndex]
        switch port {
        case floatPort:
            if let data = pipelinePackage.data as? Float {
                if data > 0.5 {
                    signal = true
                } else if data < 0.5 {
                    signal = false
                }
            }
        case boolPort:
            if let data = pipelinePackage.data as? Bool {
                signal = data
            }
        default: break
        }
        guard let signal = signal else {
            return
        }
        let outputID = FlowOutputID(input.nodeIndex, signal ? 0 : 1)
        do {
            try await dispatcher?.dispatch(data: signal, to: outputID)
        } catch {
            print(error)
        }
    }
}
