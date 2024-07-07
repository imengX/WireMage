//
//  ConvertNode.swift
//  WireMage
//
//  Created by imengX on 10/6/24.
//

import Foundation
import AsyncAlgorithms

class SignalConvertNode: ProcessingBasicNode, FlowNodePortProtocol {
    lazy var outputs: [FlowPort] = [signalValuePort]
    lazy var inputs: [FlowPort] = [floatPort, boolPort]

    let floatPort = FlowPort(name: "floatPort\n(value>0)", type: .floatValue)
    let boolPort = FlowPort(name: "boolPort\n(true)", type: .boolValue)
    let signalValuePort = FlowPort(name: "signal", type: .signal)

    override func handlePackage(pipelinePackage: PipelinePackage) async throws {
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

    override func handlePackage(pipelinePackage: PipelinePackage) async throws {
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

class DirectionConvertNode: ProcessingBasicNode, FlowNodePortProtocol {
    lazy var outputs: [FlowPort] = [go, back, left, right]
    lazy var inputs: [FlowPort] = [polar]

    let polar = FlowPort(name: "极坐标", type: .polarValue)

    let go = FlowPort(name: "前进", type: .signal)
    let back = FlowPort(name: "后退", type: .signal)
    let left = FlowPort(name: "左转", type: .signal)
    let right = FlowPort(name: "右转", type: .signal)

    lazy var mapper: [CarControlNode.Signal: FlowPort] = [
        .go: go,
        .back: back,
        .left: left,
        .right: right
    ]

    override func handlePackage(pipelinePackage: PipelinePackage) async throws {
        let input = pipelinePackage.wire.input
//        let data = pipelinePackage.data

        let inputPort = inputs[pipelinePackage.wire.input.portIndex]

        switch inputPort {
        case polar:
            guard let data = pipelinePackage.data as? PolarValue,
                  let signal = CarControlNode.Signal(polarValue: data),
                  let outputPort = mapper[signal] else { return }
            try await self.dispatch(nodeID: input.nodeIndex, data: signal, to: outputPort)
        default : break
        }
    }
}

class DebounceConvertNode: ProcessingBasicNode, FlowNodePortProtocol {
    lazy var outputs: [FlowPort] = [signalValuePort]
    lazy var inputs: [FlowPort] = [signalValuePort]

    let signalValuePort = FlowPort(name: "signal", type: .signal)

    let channel = AsyncChannel<PipelinePackage>()

    required init(name: String, id: WMNodeID = UUID().uuidString) {
        super.init(name: name, id: id)
        Task {
            for await data in channel.debounce(for: .seconds(0.5)) {
                let input = data.wire.input
                let outputID = FlowOutputID(input.nodeIndex, 0)
                try await dispatcher?.dispatch(data: data, to: outputID)
            }
        }
    }

    override func handlePackage(pipelinePackage: PipelinePackage) async throws {
        await channel.send(pipelinePackage)
    }
}
