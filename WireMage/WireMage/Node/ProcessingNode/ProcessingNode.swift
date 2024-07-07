//
//  ProcessingNode.swift
//  WireMage
//
//  Created by imengX on 17/05/2024.
//

import Foundation
import SwiftUI

class ProcessingBasicNode: WMNodeProtocol, PipelineNode {
    var dispatcher: PipelineDispatchProtocol?
    
    let id: WMNodeID
    let name: String

    required init(name: String, id: WMNodeID = UUID().uuidString) {
        self.id = id
        self.name = name
    }

    func handlePackage(pipelinePackage: PipelinePackage) async throws {
        print(pipelinePackage)
        print(pipelinePackage.data)
//        let defaultPackageHandler = self as PipelineNode
        let input = pipelinePackage.wire.input
        let outputID = FlowOutputID(input.nodeIndex, 0)
        do {
            try await dispatcher?.dispatch(data: pipelinePackage.data, to: outputID)
        } catch {
            print(error)
        }
    }
}

class PrintNode: ProcessingBasicNode, FlowNodePortProtocol {
    let inputs: [FlowPort] = [
        FlowPort(name: "bool", type: .boolValue),
        FlowPort(name: "float", type: .floatValue)
    ]
    let outputs: [FlowPort] = []

    override func handlePackage(pipelinePackage: PipelinePackage) async throws {
        print(pipelinePackage)
//        print(pipelinePackage.data)
    }
}

class PolarConvertNode: ProcessingBasicNode, FlowNodePortProtocol {
    let inputs: [FlowPort] = [FlowPort(name: "vector", type: .vectorValue)]
    lazy var outputs: [FlowPort] = [polarValuePort]

    let polarValuePort = FlowPort(name: "polar", type: .polarValue)

//    // 方法：将x和y转换为极坐标
//    static func convertToPolar(x: Float, y: Float) -> PolarValue {
//        // 计算半径
//        let radius = sqrt(x * x + y * y)
//
//        // 计算角度
//        let angle = atan2(y, x) * 180 / Float.pi
//
//        // 返回极坐标
//        return PolarValue(radius: radius, angle: angle)
//    }

    override func handlePackage(pipelinePackage: PipelinePackage) async throws {
        guard let data = pipelinePackage.data as? VectorValue else { return }
        do {
            try await dispatch(
                nodeID: pipelinePackage.wire.input.nodeIndex, data: data, to: polarValuePort
            )
        } catch {
            print(error)
        }
    }
}

