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
    @State private var showAlert = false
    @State private var nodeName: String = ""

//    @State var controls: [ControlNode.Type] = []
    @State var patch = Patch(nodes: [], wires: [])

    @State var selection = Set<NodeIndex>()

    func addNode(with name: String) {
        let controlType = Joystick.self
        let newNode = Node(name: name, titleBarColor: Color.red, inputs: controlType.inputs, outputs: controlType.outputs)
        patch.nodes.append(newNode)
    }

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                NodeEditor(patch: $patch, selection: $selection)
                Button("Add Node") {
                    showAlert.toggle()
                }.padding()
                ContentView2()
            }
            .alert(Text("Alert Title"), isPresented: $showAlert) {
                TextField("Enter your node name", text: $nodeName)
                if nodeName.isEmpty == false {
                    Button("OK", role: .none) {
                        addNode(with: nodeName)
                        showAlert.toggle()
                    }
                }
                Button("Cancel", role: .cancel) {
                    showAlert.toggle()
                }
            }
        }
        DocumentGroup(newDocument: WireMageDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}

func randomPatch() -> Patch {
    var randomNodes: [Node] = []
    for n in 0 ..< 50 {
        let randomPoint = CGPoint(x: 1000 * Double.random(in: 0 ... 1),
                                  y: 1000 * Double.random(in: 0 ... 1))
        randomNodes.append(Node(name: "node\(n)",
                                position: randomPoint,
                                inputs: ["In"],
                                outputs: ["Out"]))
    }

    var randomWires: Set<Wire> = []
    for n in 0 ..< 50 {
        randomWires.insert(Wire(from: OutputID(n, 0), to: InputID(Int.random(in: 0 ... 49), 0)))
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

