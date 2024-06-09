//
//  ViewNode.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation
import SwiftUI
import Controls

protocol ViewNodeProtocol: WMNodeProtocol, View, Hashable {}

struct ControlViewNode<ContentView: ControlView & ViewNodeColorConfiguration>: ViewNodeProtocol, FlowNodePortProtocol, PipelineNode {

    mutating func setPipeline(_ pipeline: PipelineForNodeProtocol, nodeIndex: FlowNodeIndex) {
        self.pipeline = pipeline
        self.nodeIndex = nodeIndex
    }
    
    var nodeIndex: FlowNodeIndex?
    var pipeline: PipelineForNodeProtocol?

    static func == (lhs: ControlViewNode<ContentView>, rhs: ControlViewNode<ContentView>) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }

    let name: String

    @Environment(\.viewNodeEnvironment) var viewNodeEnvironment
    @State var values: ContentView.Value = ContentView.Value.cncvDefaultValue {
        didSet {
            guard let nodeIndex = self.nodeIndex else { return }
            if let valueMapper = values as? [FlowPort: Float] {
                for enumerated in outputs.enumerated() {
                    guard let data = valueMapper[enumerated.element] else { return }
                    let portIndex = enumerated.offset
                    Task {
                        do {
                            try await self.pipeline?.dispatch(data: data, to: FlowOutputID(nodeIndex, portIndex))
                        } catch {
                            print(error)
                        }
                    }
                }
            } else {
                Task {
                    do {
                        try await self.pipeline?.dispatch(data: values, to: FlowOutputID(nodeIndex, 0))
                    } catch {
                        print(error)
                    }
                }
            }

//            guard let data = data else { return }

        }
    }

//    weak var pipeline: PipelineForNodeProtocol?
    let inputs: [FlowPort]
    let outputs: [FlowPort]

    init(name: String) {
        self.name = name
        let portDefine = (ContentView.self as? FlowNodePortDefineProtocol.Type)
        self.inputs = portDefine?.inputs ?? []
        self.outputs = portDefine?.outputs ?? []
    }

    var body: some View {
        ContentView(name: name, value: Binding(get: {
            return values
        }, set: { newValue in
            values = newValue
        }))
        .viewNodeColorConfiguration(with: viewNodeEnvironment)
    }
}

struct ViewNodeEnvironment {
    let id: UUID = UUID()
    var name: String
    var position: CGPoint?
    var backgroundColor: Color = .gray
    var foregroundColor: Color = .red
}

struct ViewNodeEnvironmentKey: EnvironmentKey {
    static var defaultValue: ViewNodeEnvironment = ViewNodeEnvironment(name: "未命名")
}

extension EnvironmentValues {
    var viewNodeEnvironment: ViewNodeEnvironment {
        get { self[ViewNodeEnvironmentKey.self] }
        set { self[ViewNodeEnvironmentKey.self] = newValue }
    }
}

extension View {
    func viewNodeEnvironment(_ environmentValue: ViewNodeEnvironment) -> some View {
        environment(\.viewNodeEnvironment, environmentValue)
    }
}

protocol ViewNodeConfiguration: View {

}

protocol ViewNodeColorConfiguration: View {
    func backgroundColor(_ backgroundColor: Color) -> Self
    func foregroundColor(_ foregroundColor: Color) -> Self
}

extension ViewNodeColorConfiguration {
    func viewNodeColorConfiguration(with environment: ViewNodeEnvironment) -> Self {
        var node = self
        node = node.foregroundColor(environment.foregroundColor)
        node = node.backgroundColor(environment.backgroundColor)
        return node
    }
}
