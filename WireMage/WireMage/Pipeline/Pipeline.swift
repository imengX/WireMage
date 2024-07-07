//
//  Pipeline.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation
import Observation

//@Observable
class PipelineEventDispatcher: FlowNodePortProtocol {

    var nodeIndex: FlowNodeIndex?
    var pipeline: Pipeline?

    var inputs: [FlowPort]
    var outputs: [FlowPort]

    init(pipeline: Pipeline? = nil, inputs: [FlowPort], outputs: [FlowPort]) {
        self.pipeline = pipeline
        self.inputs = inputs
        self.outputs = outputs
    }

    func dispatch(data: PipelinePackage.Data) async throws {
        guard let nodeIndex = nodeIndex else { return }
        try await self.pipeline?.dispatch(data: data, to: FlowOutputID(nodeIndex, 0))
    }

    func dispatch(data: PipelinePackage.Data, to port: FlowPort) async throws {
        guard let nodeIndex = nodeIndex else { return }
        guard let portIndex = self.outputs.firstIndex(of: port) else {
            print("notfind port")
            return
        }
        guard let dataType = port.type.dataType,
              dataType == type(of: data)
        else {
            return
        }
        try await self.pipeline?.dispatch(
            data: data, to: FlowOutputID(nodeIndex, portIndex)
        )
    }
}

protocol PipelineNode: PipelineHandleProtocol {
    var eventDispatcher: PipelineEventDispatcher? { get }

    var dispatcher: PipelineDispatchProtocol? { get set }
}

extension PipelineNode {
    var eventDispatcher: PipelineEventDispatcher? { nil }
}

extension PipelineNode where Self: FlowNodePortProtocol {
    func dispatch(nodeID: FlowNodeIndex, data: PipelinePackage.Data, to port: FlowPort) async throws {
        guard let protIndex = self.outputs.firstIndex(of: port) else {
            print("notfind port")
            return
        }
//        guard let dataType = port.type.dataType,
//              dataType == type(of: data)
//        else {
//            return
//        }
        try await self.dispatcher?.dispatch(
            data: data, to: FlowOutputID(nodeID, protIndex)
        )
    }
}

extension PipelineNode where Self: PipelineHandleProtocol {

    func handlePackage(pipelinePackage: PipelinePackage) async throws {
        let input = pipelinePackage.wire.input
        let outputID = FlowOutputID(input.nodeIndex, 0)
        do {
            try await dispatcher?.dispatch(data: pipelinePackage.data, to: outputID)
        } catch {
            print(error)
        }
    }
}

struct PipelinePackage {
    typealias Data = Any

    let wire: FlowWire
    let data: Data
}

protocol PipelineHandleProtocol {
    func handlePackage(pipelinePackage: PipelinePackage) async throws
}

protocol PipelineDispatchProtocol {
//    func dispatch(package: PipelinePackage) {
    var pipeline: Pipeline? { get set }
    func dispatch(data: PipelinePackage.Data, to outputID: FlowOutputID) async throws
}

class Pipeline: PipelineDispatchProtocol {
    var pipeline: Pipeline? {
        get {
            return self
        }
        set {}
    }

    enum PipelineError: LocalizedError {
        case notFindIDMapping
    }

//    var nodes: [FlowNodeIndex: PipelineNode] = [:]
    var wires: Set<FlowWire> = [] {
        didSet {
            reMapper()
        }
    }

    typealias Stream = AsyncThrowingStream<PipelinePackage, Error>
    lazy var stream: Stream = {
        Stream { (continuation: Stream.Continuation) -> Void in
            self.continuation = continuation
        }
    }()
    private var continuation: Stream.Continuation?

    private var outputRouteMapper: [FlowOutputID: [FlowInputID]] = [:]
    private var inputRouteMapper: [FlowInputID: [FlowOutputID]] = [:]

    init() {
//        self.nodes.enumerated().forEach { element in
//            nodes[element.offset]?.pipeline = self
//        }

//        Task(priority: .high, operation: {
//            for try await package in self.stream {
//                if let node = nodes[package.wire.input.nodeIndex] {
//                    //                    await self.pipeline.dispatch(package: package, to: node)
//                    let _ = await node.handlePackage(pipelinePackage: package)
//                }
//            }
//        })
    }

    func reMapper() {
        outputRouteMapper = wires.lazy.reduce(into: [:], { partialResult, wire in
            partialResult[wire.output] = partialResult[wire.output] ?? []
            partialResult[wire.output]?.append(wire.input)
        })
        inputRouteMapper = wires.lazy.reduce(into: [:], { partialResult, wire in
            partialResult[wire.input] = partialResult[wire.input] ?? []
            partialResult[wire.input]?.append(wire.output)
        })
    }

    func dispatch(package: PipelinePackage) {
        continuation?.yield(package)
    }

    func dispatch(data: PipelinePackage.Data, to outputID: FlowOutputID) async throws {
        guard let inputIDs = outputRouteMapper[outputID] else {
//            print(outputID)
//            throw PipelineError.notFindIDMapping
            return
        }
        for inputID in inputIDs {
            let wire = FlowWire(from: outputID, to: inputID)
            //            let _ = await dispatch(package: PipelinePackage(wire: wire, data: data))
            let package = PipelinePackage(wire: wire, data: data)
            dispatch(package: package)
//            if let node = nodes[package.wire.input.nodeIndex] {
//                //                    await self.pipeline.dispatch(package: package, to: node)
//                let _ = await node.handlePackage(pipelinePackage: package)
//            }

        }
    }

//    func dispatch(data: PipelinePackage.Data, to output: FlowPort) async throws {
//
//    }


}
