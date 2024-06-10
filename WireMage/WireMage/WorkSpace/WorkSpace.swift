//
//  WorkSpace.swift
//  WireMage
//
//  Created by imengX on 10/6/24.
//

import SwiftUI
import Flow

struct WorkSpace: View {
    let pipeline: PipelineProtocol
    let patch: FlowPatch
    var nodes: [FlowNodeIndex: WMNodeProtocol]
    var viewNodes: [FlowNodeIndex: any View]
    let viewNodesKeys: [FlowNodeIndex]
    let layoutConstants: LayoutConstants

    init(nodes: [FlowNodeIndex : WMNodeProtocol], patch: FlowPatch, layout: LayoutConstants) {
        self.nodes = nodes
//        nodes = patch.nodes.enumerated().reduce(into: [:]) { partialResult, enumElement in
//            let nodeID: Flow.NodeIndex = enumElement.offset
//            if let nodeType = nodeTypes[nodeID] {
//                partialResult[nodeID] = enumElement.element
////                partialResult[nodeID] = nodeType.init(with: nodeID, node: enumElement.element)
//            }
//        }
        var pipelineNodes = [FlowNodeIndex: PipelineNode]()
        var viewNodes = [FlowNodeIndex: any ViewNodeProtocol]()
        nodes.forEach { element in
            if let node = element.value as? PipelineNode {
                pipelineNodes[element.key] = node
            }
            if let node = element.value as? (any ViewNodeProtocol) {
                viewNodes[element.key] = node
            }
        }
        let pipeLine = Pipeline(nodes: pipelineNodes, wires: patch.wires)
        nodes.forEach { element in
            if var obj = element.value as? any PipelineNode {
                obj.setPipeline(pipeLine, nodeIndex: element.key)
            }
        }
        self.viewNodes = viewNodes.reduce(into: [FlowNodeIndex: any View](), { partialResult, element in
            if var obj = element.value as? any PipelineNode & ViewNodeProtocol {
                obj.setPipeline(pipeLine, nodeIndex: element.key)
                partialResult[element.key] = obj
            } else {
                partialResult[element.key] = element.value
            }
        })
        self.viewNodesKeys = viewNodes.keys.map({ index in
            return index
        })
        self.pipeline = pipeLine
        self.patch = patch
        self.layoutConstants = layout
    }

    var body: some View {
        ZStack {
            ForEach(0..<viewNodesKeys.count, id: \.self) { index in
                let key = viewNodesKeys[index]
                if let view = viewNodes[key] {
                    if patch.nodes.count > key {
                        let flowNode = patch.nodes[key]
                        AnyView(view).position(flowNode.position).offset(CGSize(width: layoutConstants.nodeWidth / 2, height: layoutConstants.nodeTitleHeight))
                    } else {
                        AnyView(view)
                    }
                }
            }
        }
    }
}
