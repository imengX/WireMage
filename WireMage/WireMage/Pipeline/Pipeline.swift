//
//  Pipeline.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation

protocol PipelineNode {
//    case control(any View.Type)
//    case processing(Any.Type)
//    case terminal(Any.Type)
//    case custom(String)

    var pipeline: PipelineForNodeProtocol? { get set }
    mutating func setPipeline(_ pipeline: PipelineForNodeProtocol, nodeIndex: FlowNodeIndex)
    func handlePackage(pipelinePackage: PipelinePackage) async
}

extension PipelineNode where Self: FlowNodePortProtocol {
    func dispatch(nodeID: FlowNodeIndex, data: PipelinePackage.Data, to port: FlowPort) async throws {
        guard let protIndex = self.outputs.firstIndex(of: port) else {
            print("notfind port")
            return
        }
        guard let dataType = port.type.dataType,
              dataType == type(of: data)
        else {
            return
        }
        try await self.pipeline?.dispatch(
            data: data, to: FlowOutputID(nodeID, protIndex)
        )
    }
}

extension PipelineNode {
    func handlePackage(pipelinePackage: PipelinePackage) async {
        let input = pipelinePackage.wire.input
        let outputID = FlowOutputID(input.nodeIndex, 0)
        do {
            try await pipeline?.dispatch(data: pipelinePackage.data, to: outputID)
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

protocol PipelineForNodeProtocol: AnyObject {
    func dispatch(package: PipelinePackage)
    func dispatch(data: PipelinePackage.Data, to outputID: FlowOutputID) async throws
//    func dispatch(data: PipelinePackage.Data, to output: FlowPort) async throws
}

//protocol PipelineForViewNodeProtocol: AnyObject {
//    func dispatch(data: PipelinePackage.Data, to portID: PortIndex) async throws
//}

protocol PipelineProtocol {
}

class Pipeline: PipelineProtocol, PipelineForNodeProtocol {
    enum PipelineError: LocalizedError {
        case notFindIDMapping
    }

    let nodes: [FlowNodeIndex: PipelineNode]

    typealias Stream = AsyncThrowingStream<PipelinePackage, Error>
    private lazy var stream: Stream = {
        Stream { (continuation: Stream.Continuation) -> Void in
            self.continuation = continuation
        }
    }()
    private var continuation: Stream.Continuation?

    private let outputRouteMapper: [FlowOutputID: [FlowInputID]]
    private let inputRouteMapper: [FlowInputID: [FlowOutputID]]

    init(nodes: [FlowNodeIndex: PipelineNode], wires: Set<FlowWire>) {
        self.nodes = nodes
        outputRouteMapper = wires.lazy.reduce(into: [:], { partialResult, wire in
            partialResult[wire.output] = partialResult[wire.output] ?? []
            partialResult[wire.output]?.append(wire.input)
        })
        inputRouteMapper = wires.lazy.reduce(into: [:], { partialResult, wire in
            partialResult[wire.input] = partialResult[wire.input] ?? []
            partialResult[wire.input]?.append(wire.output)
        })
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
//            dispatch(package: )
            if let node = nodes[package.wire.input.nodeIndex] {
                //                    await self.pipeline.dispatch(package: package, to: node)
                let _ = await node.handlePackage(pipelinePackage: package)
            }

        }
    }

//    func dispatch(data: PipelinePackage.Data, to output: FlowPort) async throws {
//
//    }


}
