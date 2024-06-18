//
//  ControlNodeContentView.swift
//  WireMage
//
//  Created by imengX on 9/6/24.
//

import SwiftUI
import Controls

protocol SingleFloatValueControlView: ControlView, FlowNodePortDefineProtocol {
    init(name: String, value: Binding<Float>)
}

extension SingleFloatValueControlView {
    static var outputs: [FlowPort] { [.valuePort] }
}

extension Joystick: ControlView, FlowNodePortDefineProtocol {
    static var defaultSize: CGSize { return CGSize(width: 140, height: 140) }

    static var outputs: [FlowPort] = [polar, radiusPort, anglePort]

    static let polar = FlowPort(name: "极坐标", type: .polarValue)
    static let radiusPort = FlowPort(name: "radius", type: .floatValue)
    static let anglePort = FlowPort(name: "angle", type: .floatValue)

    init(name: String, value: Binding<[FlowPort: Any]>) {
        let origin: Float = 0
        self.init(radius: .init(get: {
            value.wrappedValue[Self.radiusPort] as? Float ?? origin
        }, set: { newValue in
            value.wrappedValue[Self.radiusPort] = newValue
            if let angle = value.wrappedValue[Self.polar] as? PolarValue {
                value.wrappedValue[Self.polar] = PolarValue(radius: newValue, angle: angle.angle)
            }
        }), angle: .init(get: {
            value.wrappedValue[Self.anglePort] as? Float ?? origin
        }, set: { newValue in
            value.wrappedValue[Self.anglePort] = newValue
            if let radius = value.wrappedValue[Self.radiusPort] as? Float {
                let angle = newValue * 360
                value.wrappedValue[Self.polar] = PolarValue(radius: radius, angle: Angle(degrees: Double(angle)))
            }
        }))
    }
}

extension Joystick: ViewNodeColorConfiguration {}

extension XYPad: ControlView, FlowNodePortDefineProtocol {
    static var defaultSize: CGSize { return CGSize(width: 140, height: 140) }

    static var outputs: [FlowPort] = [xPort, yPort]

    static let xPort = FlowPort(name: "x", type: .floatValue)
    static let yPort = FlowPort(name: "y", type: .floatValue)

    init(name: String, value: Binding<[FlowPort: Float]>) {
        let origin: Float = 0
        self.init(x: .init(get: {
            value.wrappedValue[Self.xPort] ?? origin
        }, set: { newValue in
            value.wrappedValue[Self.xPort] = newValue
        }), y: .init(get: {
            value.wrappedValue[Self.yPort] ?? origin
        }, set: { newValue in
            value.wrappedValue[Self.yPort] = newValue
        }))
    }
}

extension XYPad: ViewNodeColorConfiguration {}

extension ArcKnob: SingleFloatValueControlView {
    static var defaultSize: CGSize { return CGSize(width: 140, height: 140) }

    init(name: String, value: Binding<Float>) {
        self.init(name, value: value)
    }
}

extension ArcKnob: ViewNodeColorConfiguration {}

extension SmallKnob: SingleFloatValueControlView {
    static var defaultSize: CGSize { return CGSize(width: 140, height: 140) }

    init(name: String, value: Binding<Float>) {
        self.init(value: value)
    }
}

extension SmallKnob: ViewNodeColorConfiguration {}

//extension IndexedSlider: SingleFloatValueControlView {
//    static var outputs: [Flow.Port] { [Flow.Port(name: "index", type: .control)] }
//
//    init(name: String, value: Binding<Int>) {
//        self.init(index: <#T##Binding<Int>#>, labels: <#T##[String]#>)
//    }
//}

extension PitchWheel: SingleFloatValueControlView {
    static var defaultSize: CGSize { return CGSize(width: 60, height: 140) }

    init(name: String, value: Binding<Float>) {
        self.init(value: value)
    }
}

extension PitchWheel: ViewNodeColorConfiguration {}

extension ModWheel: SingleFloatValueControlView {
    static var defaultSize: CGSize { return CGSize(width: 60, height: 140) }

    init(name: String, value: Binding<Float>) {
        self.init(value: value)
    }
}

extension ModWheel: ViewNodeColorConfiguration {}

struct PrintDisplay: View, ControlView, FlowNodePortDefineProtocol, ViewNodeColorConfiguration {
    func foregroundColor(_ foregroundColor: Color) -> PrintDisplay {
        return self
    }
    
    func backgroundColor(_ backgroundColor: Color) -> PrintDisplay {
        var copy = self
        copy.backgroundColor = backgroundColor
        return self
    }

    static var defaultSize: CGSize { return CGSize(width: 200, height: 140) }

    static var inputs: [FlowPort] = [
        FlowPort(name: "bool", type: .boolValue),
        FlowPort(name: "float", type: .floatValue)
    ]

    var backgroundColor = Color.clear
    let name: String

    @Binding var printValue: String

    init(name: String, value: Binding<String>) {
        let origin: Float = 0
        self.name = name
        self._printValue = value
        //        self.value = value
    }

    var body: some View {
        VStack {
            Text(name)
            Spacer()
            Text(printValue)
        }.background(
            backgroundColor
        ).padding()
    }
}
