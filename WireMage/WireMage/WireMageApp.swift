//
//  WireMageApp.swift
//  WireMage
//
//  Created by imengX on 14/05/2024.
//

import SwiftUI
import Flow
import Controls
import PartitionKit
import Popovers


struct ContentView2: View {
    var vExample: some View {
        VPart(top: {
            RoundedRectangle(cornerRadius: 25).foregroundColor(.purple)
        }) {
            Circle().foregroundColor(.yellow)
        }
    }

    var hExample: some View {
        HPart(left: {
            RoundedRectangle(cornerRadius: 10).foregroundColor(.blue)
        }) {
            Circle().foregroundColor(.orange)
        }
    }

    var nestedExample: some View {
        VPart(top: {
            hExample
        }) {
            vExample
        }
    }

    var gridExample: some View {
        GridPart(topLeft: {
            RoundedRectangle(cornerRadius: 25).foregroundColor(.purple)
        }, topRight: {
            Circle().foregroundColor(.yellow)
        }, bottomLeft: {
            Circle().foregroundColor(.green)
        }) {
            RoundedRectangle(cornerRadius: 25).foregroundColor(.blue)
        }
    }

    var nestedGridsExample: some View {
        GridPart(topLeft: {
            gridExample
        }, topRight: {
            gridExample
        }, bottomLeft: {
            gridExample
        }) {
            gridExample
        }
    }

    var body: some View {
        nestedGridsExample
    }
}

@main
struct WireMageApp: App {

    @State private var addNodePanel = false
    @State private var editNodeView = false {
        didSet {
            pan = .zero
            zoom = 1
        }
    }

    @State var patch = Patch(nodes: [], wires: [])

    @State var selection = Set<FlowNodeIndex>()

    @State var nodes: [WMNodeProtocol] = []

    @State var pan: CGSize = .zero
    @State var zoom: CGFloat = 1

    let layout: LayoutConstants = LayoutConstants()

    func addNode(_ node: WMNodeProtocol) {
        let portNode = (node as? FlowNodePortProtocol)
        let flowNode = FlowNode(
            name: node.name, 
            titleBarColor: .red,
            inputs: portNode?.inputs ?? [],
            outputs: portNode?.outputs ?? []
        )
        nodes.append(node)
        patch.nodes.append(flowNode)
    }

    func deleteNodes(at indices: Set<FlowNodeIndex>) {
        let indexSetToRemove = IndexSet(indices)
        nodes.remove(atOffsets: indexSetToRemove)
        patch.nodes.remove(atOffsets: indexSetToRemove)
    }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0, content: {
                HStack( content: {
                    if editNodeView {
                        if addNodePanel {
                            Text("添加组件").bold().padding()
                            Spacer()
                            Button("完成") {
                                addNodePanel.toggle()
                            }
                        } else {
                            Text("编辑").bold().padding()
                            Spacer()
                            Button("删除") {
                                deleteNodes(at: selection)
                                selection.removeAll()
                            }.disabled(selection.isEmpty)
                            Button("添加") {
                                addNodePanel.toggle()
                            }
                            Button("完成") {
                                editNodeView.toggle()
                            }
                        }
                    } else {
                        Text("控制面板").bold().padding()
                        Spacer()
                        Button("编辑") {
                            editNodeView.toggle()
                        }
                    }
                    Spacer().frame(width: 10)
                }).zIndex(3)
                Divider().zIndex(3)
                ZStack(alignment: .topLeading, content: {
                    if editNodeView {
                        Color(hue: 1.0, saturation: 0, brightness: 0.98)
                            .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
                            .scaleEffect(zoom, anchor: UnitPoint(x: 0, y: 0))
                            .offset(pan)
                    }
                    WorkSpace(nodes: nodes, patch: patch, layout: layout)
                        .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
                        .scaleEffect(zoom, anchor: UnitPoint(x: 0, y: 0))
                        .offset(pan)
                        .opacity(editNodeView ? 0.2 : 1)
                    if editNodeView {
                        if addNodePanel {
                            NodeCreateView { node in
                                addNode(node)
                                addNodePanel.toggle()
                            }
                        } else {
                            NodeEditor(patch: $patch, selection: $selection, layout: layout)
                                .onTransformChanged({ pan, zoom in
                                    self.pan = CGSize(width: pan.width * zoom, height: pan.height * zoom)
                                    self.zoom = zoom
                                    print(pan, zoom)
                                })
                                .portColor(for: .vectorValue, Gradient(colors: [.yellow, .blue]))
                                .portColor(for: .polarValue, Gradient(colors: [.purple, .purple]))
                                .ignoresSafeArea(.container, edges: [.bottom, .horizontal])
                        }
                    }
                }).zIndex(1)
                Spacer()
            })
        }
        DocumentGroup(newDocument: WireMageDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}

func randomPatch() -> Patch {
    var randomNodes: [FlowNode] = []
    for n in 0 ..< 50 {
        let randomPoint = CGPoint(x: 1000 * Double.random(in: 0 ... 1),
                                  y: 1000 * Double.random(in: 0 ... 1))
        randomNodes.append(FlowNode(name: "node\(n)",
                                position: randomPoint,
                                inputs: ["In"],
                                outputs: ["Out"]))
    }

    var randomWires: Set<FlowWire> = []
    for n in 0 ..< 50 {
        randomWires.insert(FlowWire(from: FlowOutputID(n, 0), to: FlowInputID(Int.random(in: 0 ... 49), 0)))
    }
    return Patch(nodes: randomNodes, wires: randomWires)
}

//func simplePatch() -> Patch {
//    let generator = Node(name: "generator", titleBarColor: Color.cyan, outputs: ["out"])
//    let processor = Node(name: "processor", titleBarColor: Color.red, inputs: ["in"], outputs: ["out"])
//    let mixer = Node(name: "mixer", titleBarColor: Color.gray, inputs: ["in1", "in2"], outputs: ["out"])
//    let output = Node(name: "output", titleBarColor: Color.purple, inputs: ["in"])
//
//    let nodes = [generator, processor, generator, processor, mixer, output]
//
//    let wires = Set([Wire(from: OutputID(0, 0), to: InputID(1, 0)),
//                     Wire(from: OutputID(1, 0), to: InputID(4, 0)),
//                     Wire(from: OutputID(2, 0), to: InputID(3, 0)),
//                     Wire(from: OutputID(3, 0), to: InputID(4, 1)),
//                     Wire(from: OutputID(4, 0), to: InputID(5, 0))])
//    controls
//    let nodes = [generator, processor, generator, processor, mixer, output]
//
//
//    var patch = Patch(nodes: nodes, wires: wires)
//    patch.recursiveLayout(nodeIndex: 5, at: CGPoint(x: 800, y: 50))
//    return patch
//}

