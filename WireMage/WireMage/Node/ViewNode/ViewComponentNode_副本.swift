//
//  ViewComponentNode.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation
import SwiftUI
import Controls

struct ControlNodeView<ContentView: View, ValueType>: ViewNodeProtocol {
    @ViewBuilder var contentView: ContentView
    weak var pipeline: PipelineForNodeProtocol?

    let name: String

    init(name: String, contentView: ContentView) {
        self.name = name
        self.contentView = contentView
    }

    var body: some View {
        contentView
    }
}

struct ArcKnobNode: ControlNodeView<ArcKnob, Float>, FlowNodePortProtocol, ViewNodeProtocol {

class ArcKnobNode: ControlNodeView<ArcKnob, Float>, FlowNodePortProtocol, ViewNodeProtocol {
    var inputs: [FlowPort] { [] }
    var outputs: [FlowPort] { [FlowPort(name: "value", type: .floatValue)] }

    var nodeView: ArcKnob? {
        ArcKnob(
            self.name,
            value: Binding(get: {
                let value = self.value.valueWrapper
                return value ?? 0
                //                return self.exposeValue ?? 0
            }, set: { newValue in
                self.value.valueWrapper = newValue
            })
        )
    }
}

struct SmallKnobNode: FlowNodePortProtocol, View {
    var name: String

//    @State var value: Float
    @State var value: Float

    init(name: String) {
        self.name = name
        value = 0
    }

    typealias NodeViewType = SmallKnob

    var inputs: [FlowPort] { [] }
    var outputs: [FlowPort] { [FlowPort(name: "value", type: .floatValue)] }

    var body: some View {
        SmallKnob(
            value: Binding(get: {
                self.value
            }, set: { newValue in
                self.value = newValue
            }),
            range: 0...4
        )
    }
}

class IndexedSliderNode: ControlNode<IndexedSlider, Int>, FlowNodePortProtocol, ViewNodeProtocol {
    var inputs: [FlowPort] { [] }
    var outputs: [FlowPort] { [FlowPort(name: "index", type: .intValue)] }

    var nodeView: IndexedSlider? {
//        IndexedSlider(
//            index: Binding(get: {
//                return self.exposeValue ?? 0
//            }, set: { newValue in
////                self.value = newValue
//            }),
//            labels: self.inputs.map({ Port in
//                Port.name
//            })
//        )
        return nil
    }
}

extension Ribbon: FloatValueViewProtocol {
    init(value: Binding<Float>) {
        self.init(position: value)
    }
}

class RibbonNode: FloatValueViewNode<Ribbon>,FlowNodePortProtocol, ViewNodeProtocol {
    typealias NodeViewType = Ribbon
    var inputs: [FlowPort] { [] }
    var outputs: [FlowPort] { [FlowPort(name: "position", type: .floatValue)] }
}

extension PitchWheel: FloatValueViewProtocol {}

class PitchWheelNode: FloatValueViewNode<PitchWheel>, FlowNodePortProtocol, ViewNodeProtocol {
    typealias NodeViewType = PitchWheel
    var inputs: [FlowPort] { [] }
    var outputs: [FlowPort] { [FlowPort(name: "value", type: .floatValue)] }
}

extension ModWheel: FloatValueViewProtocol {}

class ModWheelNode: FloatValueViewNode<ModWheel>, FlowNodePortProtocol, ViewNodeProtocol{
    typealias NodeViewType = ModWheel
    var inputs: [FlowPort] { [] }
    var outputs: [FlowPort] { [FlowPort(name: "value", type: .floatValue)] }
}

class JoystickNode: ControlNode<Joystick, (radius: Float, angle: Float)>, FlowNodePortProtocol, ViewNodeProtocol {
    var inputs: [FlowPort] { [] }
    var outputs: [FlowPort] { [FlowPort(name: "radius", type: .floatValue), FlowPort(name: "angle", type: .floatValue)] }

    required init(name: String) {
        super.init(name: name, defaultValue: (0,0))
    }

//    @State var radius: Float = 0
//    @State var angle: Float = 0

    var nodeView: Joystick? {
        return nil
//        Joystick(
//            radius: Binding<Float>(get: {
//                let value = self.value.valueWrapper?.radius
//                return value ?? 0
////                return self.exposeValue?.radius ?? 0
//            }, set: { newValue in
//                self.value.valueWrapper?.radius = newValue
////                self.value?.radius = newValue
//                Task {
//                    //                    try await self.pipeline?.dispatch(data: newValue, to: FlowOutputID(self.nodeID, 0))
//                }
//            }),
//            angle: Binding<Float>(get: {
//                let value = self.value.valueWrapper?.angle
//                return value ?? 0
////                return self.exposeValue?.angle ?? 0
//            }, set: { newValue in
//                self.value.valueWrapper?.angle = newValue
//                Task {
//                    //                    try await self.pipeline?.dispatch(data: newValue, to: FlowOutputID(self.nodeID, 1))
//                }
//            })
//        )
    }
//    var nodeView: Joystick? {
//        Joystick(
//            radius: $radius,
//            angle: $angle
//        )
//    }
}

class XYPadNode: ControlNode<XYPad, (x: Float, y: Float)>, FlowNodePortProtocol, ViewNodeProtocol {
    var inputs: [FlowPort] { [] }
    var outputs: [FlowPort] { [FlowPort(name: "x", type: .floatValue), FlowPort(name: "y", type: .floatValue)] }

    required init(name: String) {
        super.init(name: name, defaultValue: (0,0))
    }

    var nodeView: XYPad? {
//        XYPad(
//            x: Binding<Float>(get: {
//                return self.exposeValue?.x ?? 0
//            }, set: { newValue in
//                self.value.valueWrapper = (newValue, self.exposeValue?.y ?? 0)
//                Task {
//                    //                    try await self.pipeline?.dispatch(data: newValue, to: FlowOutputID(self.nodeID, 0))
//                }
//            }),
//            y: Binding<Float>(get: {
//                return self.exposeValue?.y ?? 0
//            }, set: { newValue in
//                self.value.valueWrapper = (self.exposeValue?.x ?? 0, newValue)
////                self.value?.y = newValue
//                Task {
//                    //                    try await self.pipeline?.dispatch(data: newValue, to: FlowOutputID(self.nodeID, 1))
//                }
//            })
//        )
        return nil
    }
}
