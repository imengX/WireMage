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
    var dispatcher: PipelineDispatchProtocol? {
        get { eventDispatcher?.pipeline }
        set {
            eventDispatcher?.pipeline = newValue as? Pipeline
        }
    }

    var eventDispatcher: PipelineEventDispatcher?

    static func == (lhs: ControlViewNode<ContentView>, rhs: ControlViewNode<ContentView>) -> Bool {
        lhs.name == rhs.name
    }

    func handlePackage(pipelinePackage: PipelinePackage) async {
        if let newValue = pipelinePackage.data as? ContentView.Value {
            self.values = newValue
        } else if ContentView.Value.self is String.Type {
            let printValue = String(describing: pipelinePackage.data)
            self.values = printValue as! ContentView.Value
            print(self.values)
        } else {
            self.values = ContentView.Value.cncvDefaultValue
        }
    }

    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }

    let name: String

    @Environment(\.viewNodeEnvironment) var viewNodeEnvironment
    @State var values: ContentView.Value = ContentView.Value.cncvDefaultValue {
        didSet {
            forwardDispatch()
        }
    }

    func forwardDispatch() {
        if let valueMapper = values as? [FlowPort: Any] {
            for value in valueMapper {
                Task {
                    do {
                        try await self.eventDispatcher?.dispatch(data: value.value, to: value.key)
                    } catch {
                        print(error)
                    }
                }
            }
        } else {
            Task {
                do {
                    try await self.eventDispatcher?.dispatch(data: values)
                } catch {
                    print(error)
                }
            }
        }
    }

    let inputs: [FlowPort]
    let outputs: [FlowPort]

    init(name: String) {
        self.name = name
        let portDefine = (ContentView.self as? FlowNodePortDefineProtocol.Type)
        self.inputs = portDefine?.inputs ?? []
        self.outputs = portDefine?.outputs ?? []
        eventDispatcher = PipelineEventDispatcher(inputs: self.inputs, outputs: self.outputs)
    }

    var body: some View {
        ContentView(name: name, value: Binding(get: {
            return values
        }, set: { newValue in
            values = newValue
        }))
        .viewNodeColorConfiguration(with: viewNodeEnvironment)
        .frame(maxWidth: ContentView.defaultSize.width, maxHeight: ContentView.defaultSize.height)
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
