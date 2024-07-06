//
//  WorkSpace.swift
//  WireMage
//
//  Created by imengX on 10/6/24.
//

import SwiftUI
import Flow
import Observation

//@Observable
struct NodeSpace: Codable {

    var patch: FlowPatch = FlowPatch(nodes: [], wires: [])
    var wmNodes: [FlowNodeIndex: WMNodeProtocol] = [:]
    
    var pipelineNodesIndex: Set<FlowNodeIndex> = []
    var viewNodesIndex: Set<FlowNodeIndex> = []

    var pipelineNodes: [FlowNodeIndex: PipelineNode] {
        pipelineNodesIndex.lazy.reduce(into: [FlowNodeIndex: PipelineNode]()) { partialResult, index in
            partialResult[index] = wmNodes[index] as? PipelineNode
        }
    }
    var viewNodes: [FlowNodeIndex: any ViewNodeProtocol] = [:]

    enum CodingKeys: CodingKey {
        case patch
        case wmNodes
        case pipelineNodesIndex
        case viewNodesIndex
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(patch, forKey: .patch)
        try container.encode(wmNodes.encode, forKey: .wmNodes)
        try container.encode(pipelineNodesIndex, forKey: .pipelineNodesIndex)
        try container.encode(viewNodesIndex, forKey: .viewNodesIndex)
    }

    init() {}

//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        patch = try container.decode(FlowPatch.self, forKey: .patch)
//        wmNodes = try container.decode([FlowNodeIndex: WMNodeStorage].self, forKey: .wmNodes).decode
//        pipelineNodesIndex = try container.decode(Set<FlowNodeIndex>.self, forKey: .pipelineNodesIndex)
//        viewNodesIndex = try container.decode(Set<FlowNodeIndex>.self, forKey: .viewNodesIndex)
//        updateViewNodes()
//    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        patch = try container.decode(FlowPatch.self, forKey: .patch)
        wmNodes = try container.decode([FlowNodeIndex: WMNodeStorage].self, forKey: .wmNodes).decode
        pipelineNodesIndex = try container.decode(Set<FlowNodeIndex>.self, forKey: .pipelineNodesIndex)
        viewNodesIndex = try container.decode(Set<FlowNodeIndex>.self, forKey: .viewNodesIndex)
        updateViewNodes()
    }

    mutating func updateViewNodes() {
        viewNodes = viewNodesIndex.lazy.reduce(into: [FlowNodeIndex: any ViewNodeProtocol]()) { partialResult, index in
            partialResult[index] = wmNodes[index] as? any ViewNodeProtocol
        }
    }

    mutating func addNode(_ node: WMNodeProtocol) {
        let portNode = (node as? FlowNodePortProtocol)
        let flowNode = FlowNode(
            name: node.name,
            titleBarColor: .red,
            inputs: portNode?.inputs ?? [],
            outputs: portNode?.outputs ?? []
        )
        let index = patch.nodes.count
        patch.nodes.append(flowNode)
        wmNodes[index] = node
        if node is PipelineNode {
            pipelineNodesIndex.insert(index)
        }
        if node is (any ViewNodeProtocol) {
            viewNodesIndex.insert(index)
            updateViewNodes()
        }
    }

    mutating func deleteNodes(at indices: Set<FlowNodeIndex>) {
        let nodeWires = patch.wires.filter { wire in
            indices.contains(wire.input.nodeIndex) || indices.contains(wire.output.nodeIndex)
        }
        nodeWires.forEach { wire in
            patch.wires.remove(wire)
        }
        patch.nodes.remove(atOffsets: IndexSet(indices))
        indices.forEach { index in
            wmNodes.removeValue(forKey: index)
            pipelineNodesIndex.remove(index)
            viewNodesIndex.remove(index)
        }
        updateViewNodes()
    }

    subscript(position index: FlowNodeIndex) -> CGPoint {
        patch.nodes[index].position
    }

    var connectedNodes: [FlowNodeIndex: PipelineHandleProtocol] = [:]
//    var connectedViewNodes: [FlowNodeIndex: any ViewNodeProtocol] = [:]

    mutating func connect(pipeline: Pipeline) {
        viewNodesIndex.removeAll()
        connectedNodes = pipelineNodes.reduce(into: [FlowNodeIndex: PipelineHandleProtocol](), { partialResult, element in
            let index = element.key
            var node = element.value
            node.dispatcher = pipeline
            node.eventDispatcher?.nodeIndex = index
            partialResult[index] = node
            if let viewNode = node as? any ViewNodeProtocol {
                viewNodes[index] = viewNode
            }
        })
        pipeline.wires = patch.wires
    }
    mutating func disconnect(pipeline: Pipeline) {
        connectedNodes.removeAll()
        pipeline.wires.removeAll()
    }
}

struct UserWorkSpace: View {
    let nodeSpace: NodeSpace
//    let pipeline: Pipeline
    let layoutConstants: LayoutConstants

    var nodes: [FlowNodeIndex: any ViewNodeProtocol] = [:]
    var viewNodesKeys: [FlowNodeIndex] = []

    init(nodeSpace: NodeSpace, layout: LayoutConstants) {
        self.nodeSpace = nodeSpace
        self.layoutConstants = layout
        self.nodes = nodeSpace.viewNodes
        self.viewNodesKeys = nodeSpace.viewNodes.keys.map({ index in
            return index
        })
    }

    var body: some View {
        ZStack {
            ForEach(0..<viewNodesKeys.count, id: \.self) { index in
                let key = viewNodesKeys[index]
                if let view = nodeSpace.viewNodes[key] {
                    AnyView(view).position(nodeSpace[position: key]).offset(CGSize(width: layoutConstants.nodeWidth / 2, height: layoutConstants.nodeTitleHeight))
                }
            }
        }
    }
}
