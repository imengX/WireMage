//
//  Pipeline.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation
import Flow

protocol PipelineNode: AnyObject {
//    case control(any View.Type)
//    case processing(Any.Type)
//    case terminal(Any.Type)
//    case custom(String)

    var pipeline: PipelineForNodeProtocol? { get set }
    func handlePackage(pipelinePackage: PipelinePackage) async
}

extension PipelineNode {
    func handlePackage(pipelinePackage: PipelinePackage) async {
        let input = pipelinePackage.wire.input
        let outputID = OutputID(input.nodeIndex, 1)
        do {
            try await pipeline?.dispatch(data: pipelinePackage.data, to: outputID)
        } catch {
            print(error)
        }
    }
}

struct PipelinePackage {
    typealias Data = Any

    let wire: Wire
    let data: Data
}

protocol PipelineForNodeProtocol {
    func dispatch(package: PipelinePackage)
    func dispatch(data: PipelinePackage.Data, to outputID: OutputID) async throws
}

protocol PipelineProtocol {
}

class Pipeline: PipelineProtocol, PipelineForNodeProtocol {
    enum PipelineError: LocalizedError {
        case notFindIDMapping
    }

    let nodes: [Flow.NodeIndex: PipelineNode]

    typealias Stream = AsyncThrowingStream<PipelinePackage, Error>
    private lazy var stream: Stream = {
        Stream { (continuation: Stream.Continuation) -> Void in
            self.continuation = continuation
        }
    }()
    private var continuation: Stream.Continuation?

    private let outputRouteMapper: [OutputID: [InputID]]
    private let inputRouteMapper: [InputID: [OutputID]]

    init(nodes: [Flow.NodeIndex: PipelineNode], wires: Set<Wire>) {
        self.nodes = nodes
        outputRouteMapper = wires.lazy.reduce(into: [:], { partialResult, wire in
            partialResult[wire.output] = partialResult[wire.output] ?? []
            partialResult[wire.output]?.append(wire.input)
        })
        inputRouteMapper = wires.lazy.reduce(into: [:], { partialResult, wire in
            partialResult[wire.input] = partialResult[wire.input] ?? []
            partialResult[wire.input]?.append(wire.output)
        })
        self.nodes.enumerated().forEach { element in
            nodes[element.offset]?.pipeline = self
        }

        Task(priority: .high, operation: {
            for try await package in self.stream {
                if let node = nodes[package.wire.input.nodeIndex] {
//                    await self.pipeline.dispatch(package: package, to: node)
                    let _ = await node.handlePackage(pipelinePackage: package)
                }
            }
        })
    }

    func dispatch(package: PipelinePackage) {
        continuation?.yield(package)
    }

    func dispatch(data: PipelinePackage.Data, to outputID: OutputID) async throws {
        guard let inputIDs = outputRouteMapper[outputID] else { throw PipelineError.notFindIDMapping }
        for inputID in inputIDs {
            let wire = Wire(from: outputID, to: inputID)
//            let _ = await dispatch(package: PipelinePackage(wire: wire, data: data))
            dispatch(package: PipelinePackage(wire: wire, data: data))
        }
    }
}
