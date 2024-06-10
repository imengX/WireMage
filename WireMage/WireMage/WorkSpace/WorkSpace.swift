//
//  WorkSpace.swift
//  WireMage
//
//  Created by imengX on 10/6/24.
//

import SwiftUI

struct WorkSpace: View {
    let pipeline: PipelineProtocol
    let patch: FlowPatch
    var nodes: [FlowNodeIndex: WMNodeProtocol]
    var viewNodes: [any View]

    init(nodes: [FlowNodeIndex : WMNodeProtocol], patch: FlowPatch) {
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
        self.viewNodes = viewNodes.reduce(into: [any ViewNodeProtocol](), { partialResult, element in
            if var obj = element.value as? any PipelineNode & ViewNodeProtocol {
                obj.setPipeline(pipeLine, nodeIndex: element.key)
                partialResult.append(obj)
            } else  {
                partialResult.append(element.value)
            }
        })
        self.pipeline = pipeLine
        self.patch = patch
    }

    var body: some View {
        ZStack {
            ForEach(0..<viewNodes.count, id: \.self) { index in
                let view = viewNodes[index]
                AnyView(view)
            }
        }
    }
}
