//
//  WMNode.swift
//  WireMage
//
//  Created by imengX on 17/05/2024.
//

import Foundation

protocol WMNodeEnvironment: Hashable {}

protocol WMNodeProtocol {
    var name: String { get }
    init(name: String)
}

struct WMNodeStorage: Codable {
    let type: WMNodeType
    let name: String
}

enum WMNodeType: String, Codable {

    case printNode
//    case polarConvertNode
    case carControlNode

    case signalConvertNode
    case boolConvertNode

    case joystickNode
    case xYPadNode
    case arcKnobNode
    case smallKnobNode
//    case indexedSliderNode
    case pitchWheelNode
    case modWheelNode
    case printDisplayNode

    private static let mapper: [WMNodeType: WMNodeProtocol.Type] = [
        .printNode: PrintNode.self,
        .carControlNode: CarControlNode.self,
        .signalConvertNode: SignalConvertNode.self,
        .boolConvertNode: BoolConvertNode.self,
        .joystickNode: JoystickNode.self,
        .xYPadNode: XYPadNode.self,
        .arcKnobNode: ArcKnobNode.self,
        .smallKnobNode: SmallKnobNode.self,
//        .indexedSliderNode: IndexedSliderNode.self,
        .pitchWheelNode: PitchWheelNode.self,
        .modWheelNode: ModWheelNode.self,
        .printDisplayNode: PrintDisplayNode.self
    ]

    init?(nodeType: WMNodeProtocol) {
        var key: WMNodeType?
        for element in WMNodeType.mapper {
            if element.value == type(of: nodeType) {
                key = element.key
                break
            }
        }
        if let key = key {
            self = key
        } else {
            return nil
        }
    }

    func nodeType() -> WMNodeProtocol.Type? {
        WMNodeType.mapper[self]
    }
}

extension [FlowNodeIndex: WMNodeProtocol] {
    var encode: [FlowNodeIndex: WMNodeStorage] {
        return self.reduce(into: [FlowNodeIndex: WMNodeStorage](), { partialResult, element in
            if let nodeType = WMNodeType(nodeType: element.value){
                partialResult[element.key] = WMNodeStorage(
                    type: nodeType,
                    name: element.value.name
                )
            }
        })
    }
}
extension [FlowNodeIndex: WMNodeStorage] {
    var decode: [FlowNodeIndex: WMNodeProtocol] {
        return self.reduce(into: [FlowNodeIndex: WMNodeProtocol](), { partialResult, element in
            partialResult[element.key] = element.value.type.nodeType()?.init(name: element.value.name)
        })
    }
}
