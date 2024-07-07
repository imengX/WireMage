//
//  WMNode.swift
//  WireMage
//
//  Created by imengX on 17/05/2024.
//

import Foundation

protocol WMNodeEnvironment: Hashable {}

typealias WMNodeID = String

protocol WMNodeProtocol {
    var id: WMNodeID { get }
    var name: String { get }
    init(name: String, id: WMNodeID)
}

struct WMNodeStorage: Codable {
    let type: WMNodeType
    let name: String
    let id: String
}

enum WMNodeType: String, Codable {

    case printNode
//    case polarConvertNode
    case carControlNode

    case signalConvertNode
    case boolConvertNode
    case throttleConvertNode
    case directionConvertNode

    case joystickNode
    case xYPadNode
    case arcKnobNode
    case smallKnobNode
//    case indexedSliderNode
    case pitchWheelNode
    case modWheelNode
    case printDisplayNode

    private static let mapper: [WMNodeType: any WMNodeProtocol.Type] = [
        .printNode: PrintNode.self,
        .carControlNode: CarControlNode.self,
        
        .signalConvertNode: SignalConvertNode.self,
        .boolConvertNode: BoolConvertNode.self,
        .throttleConvertNode: DebounceConvertNode.self,
        .directionConvertNode: DirectionConvertNode.self,

        .joystickNode: JoystickNode.self,
        .xYPadNode: XYPadNode.self,
        .arcKnobNode: ArcKnobNode.self,
        .smallKnobNode: SmallKnobNode.self,
//        .indexedSliderNode: IndexedSliderNode.self,
        .pitchWheelNode: PitchWheelNode.self,
        .modWheelNode: ModWheelNode.self,
        .printDisplayNode: PrintDisplayNode.self
    ]

    init?(nodeType: any WMNodeProtocol) {
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

    func nodeType() -> (any WMNodeProtocol.Type)? {
        WMNodeType.mapper[self]
    }
}

extension [String: WMNodeProtocol] {
    var encode: [String: WMNodeStorage] {
        return self.reduce(into: [String: WMNodeStorage](), { partialResult, element in
            if let nodeType = WMNodeType(nodeType: element.value){
                partialResult[element.key] = WMNodeStorage(
                    type: nodeType,
                    name: element.value.name,
                    id: element.value.id
                )
            }
        })
    }
}

extension [String: WMNodeStorage] {
    var decode: [String: WMNodeProtocol] {
        return self.reduce(into: [String: WMNodeProtocol](), { partialResult, element in
            partialResult[element.key] = element.value.type.nodeType()?.init(name: element.value.name, id: element.value.id)
        })
    }
}
