//
//  NodeTemplate.swift
//  WireMage
//
//  Created by imengX on 10/6/24.
//

import SwiftUI

protocol NodeTemplateProtocol: FlowNodePortProtocol, Hashable {
    var name: String { get }
    var nodeType: WMNodeProtocol.Type { get }
}

struct PortNodeTemplate {
    let name: String
    let port: FlowNodePortProtocol

    init(name: String, port: FlowNodePortProtocol) {
        self.name = name
        self.port = port
    }
}

struct NodeTemplatePreviewView<PreviewContentView: ViewNodeProtocol>: NodeTemplateProtocol, View {

    static func == (lhs: NodeTemplatePreviewView<PreviewContentView>, rhs: NodeTemplatePreviewView<PreviewContentView>) -> Bool {
        lhs.nodeType == rhs.nodeType
    }

    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }

    @Environment(\.viewNodeEnvironment) var viewNodeEnvironment

    var body: some View {
        viewNode ??
        PreviewContentView.init(name: viewNodeEnvironment.name)
    }

    let viewNode: PreviewContentView?

    var name: String {
        viewNode?.name ?? viewNodeEnvironment.name
    }

    init(_ viewNode: PreviewContentView) {
        self.viewNode = viewNode
        let portNode = viewNode as? FlowNodePortProtocol
        self.nodeType = type(of: viewNode)
        self.inputs = portNode?.inputs ?? []
        self.outputs = portNode?.outputs ?? []
    }

    init(_ viewNodeType: PreviewContentView.Type) {
        self.viewNode = nil
        let portNode = viewNodeType as? FlowNodePortDefineProtocol.Type
        self.nodeType = viewNodeType
        self.inputs = portNode?.inputs ?? []
        self.outputs = portNode?.outputs ?? []
    }

    var nodeType: WMNodeProtocol.Type
    var inputs: [FlowPort] = []
    var outputs: [FlowPort] = []
}

struct PortNodePreviewView: NodeTemplateProtocol, View {

    static func == (lhs: PortNodePreviewView, rhs: PortNodePreviewView) -> Bool {
        lhs.nodeType == rhs.nodeType
    }

    func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 0)),
        GridItem(.flexible(minimum: 0)),
        GridItem(.flexible(minimum: 0))
    ]

    let name: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(name).fixedSize(horizontal: true, vertical: true)
            }
            Divider()
            portsGroupView(with: "输入", ports: inputs)
            Divider()
            portsGroupView(with: "输出", ports: outputs)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(5)
    }

    @ViewBuilder func portsGroupView(with name: String, ports: [FlowPort]) -> some View {
        HStack(spacing: 0) {
            Text(name).fixedSize(horizontal: true, vertical: true)
            Group {
//                Color(.secondarySystemFill).frame(maxHeight: .infinity).frame(idealWidth: 1, maxHeight: .infinity)
                Color(.secondarySystemFill).frame(maxWidth: 1, maxHeight: .infinity)
                Spacer()
            }
            portsView(with: ports)
        }
    }

    @ViewBuilder func portsView(with ports: [FlowPort]) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<ports.count, id: \.self) { index in
                Text(ports[index].name).fixedSize(horizontal: true, vertical: true).background()
                if index != ports.count - 1 {
                    Divider()
                }
            }
            if ports.isEmpty == true {
                Text("无").fixedSize(horizontal: true, vertical: true)
            }
        }
    }

    init(name: String, nodeType: WMNodeProtocol.Type, inputs: [FlowPort], outputs: [FlowPort]) {
        self.name = name
        self.nodeType = nodeType
        self.inputs = inputs
        self.outputs = outputs
//        self.previewView = {
//            self.previewContent
//        }
    }

    init(_ node: WMNodeProtocol) {
        let portNode = node as? FlowNodePortProtocol
        self.name = node.name
        self.nodeType = type(of: node)
//        self.previewContent = viewNode.view ?? AnyView(EmptyView())
        self.inputs = portNode?.inputs ?? []
        self.outputs = portNode?.outputs ?? []

//        self.previewView = {
//            previewContent
//        }

//        self.init(
//            name: viewNode.name,
//            nodeType: type(of: viewNode),
//            inputs: portNode?.inputs ?? [],
//            outputs: portNode?.outputs ?? [],
//            previewContent: {
//                viewNode.view
//            }
//        )
    }


    var nodeType: WMNodeProtocol.Type

    var inputs: [FlowPort] = []
    var outputs: [FlowPort] = []
}
