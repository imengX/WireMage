//
//  ProcessingNode.swift
//  WireMage
//
//  Created by imengX on 17/05/2024.
//

import Foundation

class ProcessingBasicNode: WMNodeProtocol, PipelineNode {

    func setPipeline(_ pipeline: PipelineForNodeProtocol, nodeIndex: FlowNodeIndex) {
        _pipeline = pipeline
    }
    
    let name: String

    weak var _pipeline: (any PipelineForNodeProtocol)?

    var pipeline: PipelineForNodeProtocol? {
        get { _pipeline }
        set { _pipeline = newValue }
    }

    required init(name: String) {
        self.name = name
    }

    func handlePackage(pipelinePackage: PipelinePackage) async {
        print(pipelinePackage)
        print(pipelinePackage.data)
//        let defaultPackageHandler = self as PipelineNode
//        await defaultPackageHandler.handlePackage(pipelinePackage: pipelinePackage)
    }
}

class PrintNode: ProcessingBasicNode, FlowNodePortProtocol {
    let inputs: [FlowPort] = [FlowPort(name: "value", type: .floatValue)]
    let outputs: [FlowPort] = []
}

class CarControlNode: ProcessingBasicNode, FlowNodePortProtocol {
    let inputs: [FlowPort] = [
        FlowPort(name: "前进", type: .floatValue),
        FlowPort(name: "后退", type: .floatValue),
        FlowPort(name: "左转", type: .floatValue),
        FlowPort(name: "右转", type: .floatValue),
        FlowPort(name: "开灯", type: .floatValue),
        FlowPort(name: "关灯", type: .floatValue)
    ]
    let outputs: [FlowPort] = []
}
