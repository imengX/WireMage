//
//  NodeCreate.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation
import SwiftUI
import Controls

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

    let name: String

    var body: some View {
        HStack {
            VStack {
                portsView(with: inputs)
            }
            Text(name)
            VStack {
                portsView(with: outputs)
            }
        }
    }

    var previewView: some View {
        HStack {
            VStack {
                portsView(with: inputs)
            }
            Text(name)
            VStack {
                portsView(with: outputs)
            }
        }
    }

    @ViewBuilder func portsView(with ports: [FlowPort]) -> some View {
        ForEach(0..<ports.count, id: \.self) { index in
            Text(ports[index].name).background()
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

//action(JoystickNode.self)
//} content: {
//Joystick(radius: $radius, angle: $angle)
//    .backgroundColor(.gray.opacity(0.5))
//    .foregroundColor(.white.opacity(0.5))
//    .squareFrame(140)

    
//
//protocol WMModuleProtocol {
//    var node: WMNodeProtocol.Type { get }
//    var name: String { get }
//    var inputs: [FlowPort] { get }
//    var outputs: [FlowPort] { get }
//}
//
//struct WMModule: WMModuleProtocol {
//    let node: WMNodeProtocol.Type
//    let name: String
//    let inputs: [FlowPort]
//    let outputs: [FlowPort]
//
//    init(name: String = "untitles", inputs: [FlowPort], outputs: [FlowPort]) {
//        self.name = name
//        self.inputs = inputs
//        self.outputs = outputs
//    }
//}

//struct ProcessingTemplateView: View {
//    let template: NodeTemplateProtocol
//
//    init(template: NodeTemplateProtocol) {
//        self.template = template
//    }
//
//    var body: some View {
//        HStack {
//            VStack {
//                portsView(with: template.inputs)
//            }
//            Text(template.name)
//            VStack {
//                portsView(with: template.outputs)
//            }
//        }
//    }
//
//    @ViewBuilder func portsView(with ports: [FlowPort]) -> some View {
//        let range: Range<Int> = ports.indices
//        ForEach(range, id: \.self) { index in
//            Text(ports[index].name)
//        }
//    }
//}

struct NodeCreateGroup<Content> : View where Content : View {
    private var content: () -> Content

    @inlinable public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        Grid(content: content)
    }
}

struct NodeCreateItem<Content> : View where Content : View {
    private var alignment: HorizontalAlignment = .center
    private var spacing: CGFloat? = nil
    @ViewBuilder private var content: () -> Content
    private var action: ActionType

    @inlinable public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, action: @escaping ActionType, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.action = action
    }

    var body: some View {
        VStack {
            content()
            Spacer(minLength: spacing)
            Button(action: action, label: {
                Label("添加", systemImage: "plus.circle.fill")
            })
        }
    }
}

var controlTemplates: [any NodeTemplateProtocol & View] = [
    NodeTemplatePreviewView(JoystickNode(name: "Joystick")),
    NodeTemplatePreviewView(XYPadNode(name: "XYPad")),
    NodeTemplatePreviewView(ArcKnobNode(name: "ArcKnob")),
//    NodePreviewTemplate(IndexedSliderNode(name: "IndexedSlider")),
    NodeTemplatePreviewView(SmallKnobNode(name: "SmallKnob")),
//    NodePreviewTemplate(RibbonNode(name: "Ribbon")),
    NodeTemplatePreviewView(PitchWheelNode(name: "PitchWheel")),
    NodeTemplatePreviewView(ModWheelNode(name: "ModWheel"))
]

var moduleTemplates: [any NodeTemplateProtocol] = [
//    PortNodePreviewTemplate(PrintNode(name: "Print"))
]

typealias ActionType = () -> Void

struct NodeCreateView: View {


    @State private var nodeName: String = ""

    typealias ActionType = (WMNodeProtocol) -> Void
    var finalAction: ActionType

    @State var type: WMNodeProtocol.Type?

    init(action: @escaping ActionType){
        self.finalAction = action
    }

    func action(_ type: WMNodeProtocol.Type) {
        self.type = type
    }

    static var templates1: [any NodeTemplateProtocol & View] = [
        NodeTemplatePreviewView(JoystickNode(name: "Joystick")),
        NodeTemplatePreviewView(XYPadNode(name: "XYPad")),
        NodeTemplatePreviewView(ArcKnobNode(name: "ArcKnob")),
    //    NodePreviewTemplate(IndexedSliderNode(name: "IndexedSlider")),
        NodeTemplatePreviewView(SmallKnobNode(name: "SmallKnob")),
//        NodePreviewTemplate(RibbonNode(name: "Ribbon")),
        NodeTemplatePreviewView(PitchWheelNode(name: "PitchWheel")),
        NodeTemplatePreviewView(ModWheelNode(name: "ModWheel")),
        PortNodePreviewView(PrintNode(name: "print")),
        PortNodePreviewView(SignalConvertNode(name: "信号转换器")),
        PortNodePreviewView(CarControlNode(name: "192.168.1.9"))
    ]
    static var templates2: [any NodeTemplateProtocol & View] = [

//        NodeTemplatePreviewView(JoystickNode(name: "Joystick")),
//        NodeTemplatePreviewView(XYPadNode(name: "XYPad")),
//        NodeTemplatePreviewView(ArcKnobNode(name: "ArcKnob")),
//    //    NodePreviewTemplate(IndexedSliderNode(name: "IndexedSlider")),
//        NodeTemplatePreviewView(SmallKnobNode(name: "SmallKnob")),
    //    NodePreviewTemplate(RibbonNode(name: "Ribbon")),
//        NodeTemplatePreviewView(PitchWheelNode(name: "PitchWheel")),
//        NodeTemplatePreviewView(ModWheelNode(name: "ModWheel"))
    ]

    var templatesGroup = [templates1, templates2]

    @State var templateIndex: Int?
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        //        HStack {
        //            ForEach(templatesGroup.indices) { groupIndex in
        //                let templates = templatesGroup[groupIndex]
        let templates = NodeCreateView.templates1
        LazyHGrid(rows: columns, spacing: 20) {
            ForEach(0..<templates.count, id: \.self) { index in
                let template = templates[index]
                NodeCreateItem {
                    //                    nodeName = template.name
                    templateIndex = index
                } content: {
                    let nodeEnvironment = ViewNodeEnvironment(
                        name: template.name,
                        backgroundColor: Color(.tertiarySystemFill),
                        foregroundColor: Color(.tintColor)
                    )
                    let preview = template.environment(\.viewNodeEnvironment, nodeEnvironment)
                    AnyView(preview).frame(idealHeight: 100)
                }
            }
        }
        .padding()
        .popover(
            present: Binding(get: {
                templateIndex != nil
            }, set: { newValue in
                templateIndex = nil
            }),
            attributes: {
                $0.blocksBackgroundTouches = true
                $0.rubberBandingMode = .none
                $0.position = .relative(
                    popoverAnchors: [
                        .center,
                    ]
                )
                $0.presentation.animation = .easeOut(duration: 0.15)
                $0.dismissal.mode = .none
                $0.onTapOutside = {
                    withAnimation(.easeIn(duration: 0.15)) {
                        //                        expanding = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.4)) {
                            //                            expanding = false
                        }
                    }
                }
            }
        ) {
            if let index = self.templateIndex {
                let template = templates[index]
                let nodeEnvironment = ViewNodeEnvironment(
                    name: template.name,
                    backgroundColor: Color(.tertiarySystemFill),
                    foregroundColor: Color(.tintColor)
                )
                NodeCreateConfigurationViewPopover(name: $nodeName, content: {
                    let preview = template.environment(\.viewNodeEnvironment, nodeEnvironment)
                    AnyView(preview).frame(maxHeight: 200)
                }) {
                    let wmNode = template.nodeType.init(name: nodeName)
                    finalAction(wmNode)
                    templateIndex = nil
                } cancelAction: {
                    templateIndex = nil
                }
            }
        } background: {
            Color.black.opacity(0.1)
        }
    }
}

struct NodeCreateConfigurationView: View {

    @Binding var name: String
    var confirmAction: ActionType
    var cancelAction: ActionType

    var body: some View {
        VStack {
            TextField("输入节点名称", text: $name)
                .padding()

            Divider()

            HStack {
                Button("确定") {
                    confirmAction()
                }
                .disabled(name.isEmpty)
                //            .buttonStyle(Templates.AlertButtonStyle())
                Button("取消", role: .cancel) {
                    cancelAction()
                }
            }
        }
    }
}

import Popovers

struct NodeCreateConfigurationViewPopover<Content: View>: View {
    @State private var bgColor =
        Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)

    @Binding var name: String
    @ViewBuilder var content: Content

    var confirmAction: ActionType
    var cancelAction: ActionType

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("编辑")
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                content
                TextField("输入节点信息", text: $name)
            }
            .padding()

            Divider()

            HStack {
                Button("确定", role: .destructive) {
                    confirmAction()
                }
                .disabled(name.isEmpty)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .padding()
                Button("取消", role: .cancel) {
                    cancelAction()
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .popoverShadow(shadow: .system)
        .frame(width: 260)
//        .scaleEffect(expanding ? 1.05 : 1)
//        .scaleEffect(scaled ? 2 : 1)
//        .opacity(scaled ? 0 : 1)
        .onAppear {
            withAnimation(.spring(
                response: 0.4,
                dampingFraction: 0.9,
                blendDuration: 1
            )) {
//                scaled = false
            }
        }
    }
}

//VStack {
//    TextField("Enter your node name", text: $name)
//    HStack {
//        Button("OK", role: .destructive) {
//            confirmAction()
//        }
//        .disabled(name.isEmpty)
//        //            .buttonStyle(Templates.AlertButtonStyle())
//        Button("Cancel", role: .cancel) {
//            cancelAction()
//        }
//    }
////            ColorPicker("Alignment Guides", selection: $bgColor)
//
////            PaletteView(selectedColor: $model.selectedColor)
////                .cornerRadius(ColorViewConstants.cornerRadius)
////
////            OpacitySlider(value: $model.alpha, color: model.selectedColor)
////                .frame(height: ColorViewConstants.sliderHeight)
////                .cornerRadius(ColorViewConstants.cornerRadius)
//}

//    @ViewBuilder var controlGroup: some View {
//        NodeCreateGroup {
//            NodeCreateItem {
////                action(JoystickNode.self)
//            } content: {
//                Joystick(radius: $radius, angle: $angle)
//                    .backgroundColor(.gray.opacity(0.5))
//                    .foregroundColor(.white.opacity(0.5))
//                    .squareFrame(140)
//            }
//            NodeCreateItem {
////                action(XYPadNode.self)
//            } content: {
//                XYPad(x: $x, y: $y)
//                    .backgroundColor(.gray.opacity(0.5))
//                    .foregroundColor(.white.opacity(0.5))
//                    .cornerRadius(20)
//                    .indicatorSize(CGSize(width: 15, height: 15))
//                    .squareFrame(140)
//            }
//            NodeCreateItem {
////                action(ArcKnobNode.self)
//            } content: {
//                ArcKnob("FIL", value: $filter)
//                    .backgroundColor(.gray.opacity(0.5))
//                    .foregroundColor(.white.opacity(0.5))
//            }
//        }
//        NodeCreateGroup {
//            NodeCreateItem {
//                action(IndexedSliderNode.self)
//            } content: {
//                IndexedSlider(index: $octaveRange, labels: ["1", "2", "3"])
//                    .backgroundColor(.gray.opacity(0.5))
//                    .foregroundColor(.white.opacity(0.5))
//                    .cornerRadius(10)
//            }
//            NodeCreateItem {
//                action(SmallKnobNode.self)
//            } content: {
//                SmallKnob(value: $smallKnobValue)
//                    .backgroundColor(.gray.opacity(0.5))
//                    .foregroundColor(.white.opacity(0.5))
//            }
//        }
//        NodeCreateGroup {
//            NodeCreateItem {
//                action(RibbonNode.self)
//            } content: {
//                Ribbon(position: $ribbon)
//                    .backgroundColor(.gray.opacity(0.5))
//                    .foregroundColor(.white.opacity(0.5))
//                    .cornerRadius(5)
//                    .frame(height: 15)
//                    .padding(.leading, 140)
//            }
//        }
//        NodeCreateGroup {
//            NodeCreateItem {
//                action(PitchWheelNode.self)
//            } content: {
//                PitchWheel(value: $pitchBend)
//                    .backgroundColor(.gray.opacity(0.5))
//                    .foregroundColor(.white.opacity(0.5))
//                    .cornerRadius(10)
//                    .frame(width: 60)
//            }
//            NodeCreateItem {
//                action(ModWheelNode.self)
//            } content: {
//                ModWheel(value: $modulation)
//                    .backgroundColor(.gray.opacity(0.5))
//                    .foregroundColor(.white.opacity(0.5))
//                    .cornerRadius(10)
//                    .frame(width: 60)
//            }
//        }
//    }

