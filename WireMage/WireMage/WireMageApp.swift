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

@main
struct WireMageApp: App {

    var body: some Scene {
        DocumentGroup(newDocument: WireMageDocument(data: .init())) { file in
            ContentView(storage: file.document.data) { storage in
                file.$document.data.wrappedValue = storage
            }.task {
                if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    print(documentsURL)
                }
            }
        }
    }
}

struct ContentView: View {

    @State var nodeSpace: NodeSpace

    @State private var addNodePanel = false
    @State private var editNodeView = false {
        didSet {
            pan = .zero
            zoom = 1
//            if editNodeView {
//                nodeSpace.disconnect(pipeline: pipeline)
//            } else {
//                nodeSpace.connect(pipeline: pipeline)
//            }
        }
    }

//    var nodeSpace: NodeSpace
//    @Binding var nodeStorage: NodeStorage

    @State var selection = Set<FlowNodeIndex>()
    @State var pan: CGSize = .zero
    @State var zoom: CGFloat = 1

    let layout: LayoutConstants = LayoutConstants()
    typealias StorageAction = (_ storage: NodeStorage)->Void
    var editDoneAction: StorageAction?

    init(storage: NodeStorage, editDoneAction: StorageAction?) {
        self.nodeSpace = NodeSpace(storage: storage)
        self.editDoneAction = editDoneAction
    }
    
    var body: some View {
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
                            nodeSpace.deleteNodes(at: selection)
                            selection.removeAll()
                        }.disabled(selection.isEmpty)
                        Button("添加") {
                            addNodePanel.toggle()
                        }
                        Button("完成") {
                            editNodeView.toggle()
                            if !editNodeView {
                                editDoneAction?(nodeSpace.storage)
                            }
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
                if !addNodePanel {
                    UserWorkSpace(nodeSpace: nodeSpace, layout: layout)
                        .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
                        .scaleEffect(zoom, anchor: UnitPoint(x: 0, y: 0))
                        .offset(pan)
                        .opacity(editNodeView ? 0.2 : 1)
                }
                if editNodeView {
                    if addNodePanel {
                        NodeCreateView { node in
                            nodeSpace.addNode(node)
                            addNodePanel.toggle()
                        }
                    } else {
                        NodeEditor(patch: Binding<Patch>.init(get: {
                            nodeSpace.patch
                        }, set: { newValue in
                            nodeSpace.patch = newValue
                        }), selection: $selection, layout: layout)
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
            })
            .zIndex(1)
            Spacer()
        })
    }
}
