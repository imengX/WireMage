//
//  WorkSpace.swift
//  WireMage
//
//  Created by imengX on 10/6/24.
//

import SwiftUI
import Flow
import Observation

enum StorageError: String, LocalizedError {
    case versionConflict
    case value
}

struct NodeStorage: Codable {


    static let version: String = "1.0.0"

    private let version: String
    fileprivate (set) var patch: FlowPatch
    fileprivate (set) var wmNodes: [WMNodeID: WMNodeProtocol]

    fileprivate (set) var nodeIDMapper: [WMNodeID: FlowNodeIndex]
    fileprivate (set) var indexMapper: [FlowNodeIndex: WMNodeID]

    fileprivate (set) var pipelineNodesIndex: Set<WMNodeID>
    fileprivate (set) var viewNodesIndex: Set<WMNodeID>

    enum CodingKeys: CodingKey {
        case version

        case patch
        case wmNodes
        
        case nodeIDMapper
        case indexMapper

        case pipelineNodesIndex
        case viewNodesIndex
    }

    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(version, forKey: .version)
            try container.encode(patch, forKey: .patch)
            try container.encode(wmNodes.encode, forKey: .wmNodes)
            try container.encode(nodeIDMapper, forKey: .nodeIDMapper)
            try container.encode(indexMapper, forKey: .indexMapper)
            try container.encode(pipelineNodesIndex, forKey: .pipelineNodesIndex)
            try container.encode(viewNodesIndex, forKey: .viewNodesIndex)
        } catch {
            print(error)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        if version != Self.version {
            throw StorageError.versionConflict
        }
        patch = try container.decode(FlowPatch.self, forKey: .patch)
        wmNodes = try container.decode([WMNodeID: WMNodeStorage].self, forKey: .wmNodes).decode

        nodeIDMapper = try container.decode([WMNodeID: FlowNodeIndex].self, forKey: .nodeIDMapper)
        indexMapper = try container.decode([FlowNodeIndex: WMNodeID].self, forKey: .indexMapper)

        pipelineNodesIndex = try container.decode(Set<WMNodeID>.self, forKey: .pipelineNodesIndex)
        viewNodesIndex = try container.decode(Set<WMNodeID>.self, forKey: .viewNodesIndex)
    }

    init() {
        version = Self.version
        patch = FlowPatch(nodes: [], wires: [])
        wmNodes = [:]
        nodeIDMapper = [:]
        indexMapper = [:]
        pipelineNodesIndex = []
        viewNodesIndex = []
    }

    fileprivate mutating func updateMapper(id: WMNodeID, index: FlowNodeIndex) {
        nodeIDMapper[id] = index
        indexMapper[index] = id
    }

    subscript(id: WMNodeID) -> WMNodeProtocol? {
        get { wmNodes[id] }
    }

    fileprivate mutating func addNode(_ node: WMNodeProtocol) {
        let portNode = (node as? FlowNodePortProtocol)
        let flowNode = FlowNode(
            name: node.name,
            titleBarColor: .red,
            inputs: portNode?.inputs ?? [],
            outputs: portNode?.outputs ?? []
        )

        let index = patch.nodes.count
        patch.nodes.append(flowNode)
        wmNodes[node.id] = node
        updateMapper(id: node.id, index: index)

        if node is PipelineNode {
            pipelineNodesIndex.insert(node.id)
        }
        if node is (any ViewNodeProtocol) {
            viewNodesIndex.insert(node.id)
        }
    }

    fileprivate mutating func deleteNodes(at indices: Set<FlowNodeIndex>) {
        var wmNodes = self.wmNodes
        var pipelineNodesIndex = self.pipelineNodesIndex
        var viewNodesIndex = self.viewNodesIndex

        indices.forEach { index in
            guard let id = indexMapper[index] else { return }
            wmNodes.removeValue(forKey: id)
            pipelineNodesIndex.remove(id)
            viewNodesIndex.remove(id)
        }
//
        var tIdMapper = [WMNodeID: FlowNodeIndex]()
        var tIndexMapper = [FlowNodeIndex: WMNodeID]()

        for element in patch.deleteNodes(with: indices) {
            let oldIndex = element.key
            let newIndex = element.value
            if let id = self.indexMapper[oldIndex] {
                tIndexMapper[newIndex] = id
                tIdMapper[id] = newIndex
            }
        }

        self.wmNodes = wmNodes
        self.pipelineNodesIndex = pipelineNodesIndex
        self.viewNodesIndex = viewNodesIndex
        self.nodeIDMapper = tIdMapper
        self.indexMapper = tIndexMapper
    }
}

struct NodeSpace {
    var pipeline = Pipeline()

    var storage: NodeStorage
    var patch: FlowPatch {
        get { storage.patch }
        set {
            storage.patch = newValue
            pipeline.wires = newValue.wires
        }
    }

    private var pipelineNodes: [PipelineNode & WMNodeProtocol] {
        storage.pipelineNodesIndex.compactMap { id in
            self.storage[id] as? PipelineNode & WMNodeProtocol
        }
    }
    var viewNodes: [any ViewNodeProtocol] = []

    private var connectedNodes: [WMNodeID: PipelineHandleProtocol] = [:]

    init(storage: NodeStorage) {
        self.storage = storage
        connect(pipeline: pipeline)
        begin()
    }

    func begin() {
        Task {
            for try await package in self.pipeline.stream {
                if let node = self[package.wire.input.nodeIndex] {
                    //                                    if let node = nodeSpace.connectedNodes[package.wire.input.nodeIndex] {
                    //                    await self.pipeline.dispatch(package: package, to: node)
                    let _ = try await node.handlePackage(pipelinePackage: package)
                }
            }
        }
    }
//    func setStorage(storage: NodeStorage) {
//        self.storage = storage
//    }

    mutating func updateViewNodes() {
        viewNodes = storage.viewNodesIndex.lazy.compactMap({ id in
            if let connectedNode = connectedNodes[id] as? any ViewNodeProtocol {
                return connectedNode
            } else {
                return storage[id] as? any ViewNodeProtocol
            }
        })
    }

    subscript(index: FlowNodeIndex) -> PipelineHandleProtocol? {
        guard let id = storage.indexMapper[index] else { return nil }
        return connectedNodes[id]
    }

    subscript(position nodeID: WMNodeID) -> CGPoint {
        guard let index = storage.nodeIDMapper[nodeID] else { return .zero }
        return storage.patch.nodes[index].position
    }

    mutating func connect(pipeline: Pipeline) {
        var viewNodesIndex = Set<WMNodeID>()
        connectedNodes = pipelineNodes.reduce(into: [WMNodeID: PipelineHandleProtocol](), { partialResult, element in
            var node = element
            node.dispatcher = pipeline
            node.eventDispatcher?.nodeIndex = storage.nodeIDMapper[node.id]
            partialResult[node.id] = node
            if node is any ViewNodeProtocol {
                viewNodesIndex.insert(node.id)
            }
        })
        pipeline.wires = patch.wires
        storage.viewNodesIndex = viewNodesIndex
        updateViewNodes()
    }

    mutating func disconnect() {
        connectedNodes.removeAll()
    }

    mutating func addNode(_ node: WMNodeProtocol) {
        storage.addNode(node)
        updateViewNodes()
    }

    mutating func deleteNodes(at indices: Set<FlowNodeIndex>) {
        storage.deleteNodes(at: indices)
        updateViewNodes()
    }
}

struct UserWorkSpace: View {
    let nodeSpace: NodeSpace
    let layoutConstants: LayoutConstants

    var nodes: [any ViewNodeProtocol] = []
    var viewNodesKeys: [FlowNodeIndex] = []

    init(nodeSpace: NodeSpace, layout: LayoutConstants) {
        self.nodeSpace = nodeSpace
        self.layoutConstants = layout
        self.nodes = nodeSpace.viewNodes
    }

    var body: some View {
        ZStack {
            ForEach(0..<nodes.count, id: \.self) { index in
                let view = nodes[index]
                AnyView(view).position(nodeSpace[position: view.id]).offset(CGSize(width: layoutConstants.nodeWidth / 2, height: layoutConstants.nodeTitleHeight))
            }
        }
    }
}

extension FlowPatch {
    private struct NodeIndexMapper {
        fileprivate var indexMap: [NodeIndex: NodeIndex] = [:]

        subscript(originalIndex: NodeIndex, default defaultValue: NodeIndex) -> NodeIndex {
            get { indexMap[originalIndex, default: defaultValue] }
            set { indexMap[originalIndex] = newValue }
        }
    }

    mutating func deleteNodes(with indices: Set<FlowNodeIndex>) -> [NodeIndex: NodeIndex] {
        // Step 1: Remove wires that connect to the nodes being removed
        var updatedWires = Set<Wire>()
        var nodeIndexMapper = NodeIndexMapper()

        // Build a new nodes array with updated indices
        var updatedNodes = [Node]()
        for (index, node) in nodes.enumerated() {
            if !indices.contains(index) {
                updatedNodes.append(node)
                nodeIndexMapper[index, default: index] = updatedNodes.count - 1
            }
        }

        // Update wires with adjusted node indices
        for wire in wires {
            let outputNodeIndex = wire.output.nodeIndex
            let inputNodeIndex = wire.input.nodeIndex

            // Skip wires that connect to nodes being removed
            if indices.contains(outputNodeIndex) || indices.contains(inputNodeIndex) {
                continue
            }

            // Update output ID
            let updatedOutputIndex = nodeIndexMapper[outputNodeIndex, default: outputNodeIndex]
            let updatedOutput = OutputID(updatedOutputIndex, wire.output.portIndex)

            // Update input ID
            let updatedInputIndex = nodeIndexMapper[inputNodeIndex, default: inputNodeIndex]
            let updatedInput = InputID(updatedInputIndex, wire.input.portIndex)

            let updatedWire = Wire(from: updatedOutput, to: updatedInput)
            updatedWires.insert(updatedWire)
        }
        
        self = FlowPatch(nodes: updatedNodes, wires: updatedWires)
        return nodeIndexMapper.indexMap
    }
}
