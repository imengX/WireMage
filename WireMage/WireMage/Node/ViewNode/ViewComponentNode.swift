//
//  ViewComponentNode.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation
import SwiftUI
import Controls

import Flow

protocol ControlView: View {
    associatedtype Value: ControlViewValue
    init(name: String, value: Binding<Value>)
}

protocol ControlViewValue {
//    associatedtype Value
    static var cncvDefaultValue: Self { get }
//    subscript(port: FlowPort) -> Any { get set }
}

extension Dictionary: ControlViewValue where Key == FlowPort {
    static var cncvDefaultValue: Dictionary<Key, Value> {
        return [Key: Value]()
    }
}

extension Float: ControlViewValue {
    static var cncvDefaultValue: Float {
        0
    }
    
//    subscript(port: FlowPort) -> Float {
//        get {
//            return self
//        }
//        set {
//            self = newValue
//        }
//    }
}

extension FlowPort {
    static let valuePort = FlowPort(name: "value", type: .floatValue)
}

typealias JoystickNode = ControlViewNode<Joystick>
typealias XYPadNode = ControlViewNode<XYPad>
typealias ArcKnobNode = ControlViewNode<ArcKnob>
typealias SmallKnobNode = ControlViewNode<SmallKnob>
//typealias IndexedSliderNode = ControlNodeView<IndexedSlider>
typealias PitchWheelNode = ControlViewNode<PitchWheel>
typealias ModWheelNode = ControlViewNode<ModWheel>

