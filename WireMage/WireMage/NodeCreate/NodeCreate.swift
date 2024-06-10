//
//  NodeCreate.swift
//  WireMage
//
//  Created by imengX on 16/05/2024.
//

import Foundation
import SwiftUI
import Controls
import SwiftUIPager

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
        }.padding()
    }
}

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
    ]

    static var templates2: [any NodeTemplateProtocol & View] = [
        PortNodePreviewView(SignalConvertNode(name: "信号转换器")),
        PortNodePreviewView(BoolConvertNode(name: "布尔转换器")),
    ]

    static var templates3: [any NodeTemplateProtocol & View] = [
        PortNodePreviewView(PrintNode(name: "print")),
        PortNodePreviewView(CarControlNode(name: "192.168.1.9"))
    ]

    var pageData = [templates1, templates2, templates3]

    @State var templateIndex: Int?
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    @StateObject var page: Page = .first()
    var items = ["控件", "处理器", "终端"]

    var body: some View {
        VStack(spacing: 0, content: {
            Picker("Choose your starter", selection: Binding(get: {
                page.index
            }, set: { newValue in
                page.update(Page.Update.new(index: newValue))
            })) {
                ForEach(0..<items.count, id: \.self) { index in
                    Text(items[index])
                }
            }.pickerStyle(.segmented)
                .frame(height: 44)
            Pager(page: page,
                  data: Array(0..<items.count),
                  id: \.self,
                  content: { pageIndex in
                let templates = pageData[pageIndex]
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
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
                                AnyView(preview).frame(minHeight: 140)
                            }
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(5.0)
//                            .padding()
                        }
                    }
                }.frame(maxWidth: .infinity)
                    .padding()
                    .background()
                    .fullScreenCover(isPresented: Binding(get: {
                        templateIndex != nil
                    }, set: { newValue in
                        templateIndex = nil
                    }), content: {
                        let templates = pageData[page.index]
                        if let index = self.templateIndex {
                            let template = templates[index]
                            let nodeEnvironment = ViewNodeEnvironment(
                                name: template.name,
                                backgroundColor: Color(.tertiarySystemFill),
                                foregroundColor: Color(.tintColor)
                            )
                            NodeCreateConfigurationViewPopover(name: $nodeName, content: {
                                let preview = template.environment(\.viewNodeEnvironment, nodeEnvironment)
                                AnyView(preview).frame(minHeight: 140)
                            }) {
                                let wmNode = template.nodeType.init(name: nodeName)
                                finalAction(wmNode)
                                templateIndex = nil
                            } cancelAction: {
                                templateIndex = nil
                            }
                        }
                    })
            })
//            .delaysTouches(false)
        })

//        .popover(
//            present: Binding(get: {
//                templateIndex != nil
//            }, set: { newValue in
//                templateIndex = nil
//            }),
//            attributes: {
//                $0.blocksBackgroundTouches = true
//                $0.rubberBandingMode = .none
//                $0.position = .relative(
//                    popoverAnchors: [
//                        .center,
//                    ]
//                )
//                $0.presentation.animation = .easeOut(duration: 0.15)
//                $0.dismissal.mode = .none
//                $0.onTapOutside = {
//                    withAnimation(.easeIn(duration: 0.15)) {
//                        //                        expanding = true
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        withAnimation(.easeOut(duration: 0.4)) {
//                            //                            expanding = false
//                        }
//                    }
//                }
//            }
//        ) {
//    background: {
//            Color.black.opacity(0.1)
//        }
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
        VStack(spacing: 0) {  // or any other constant
            HStack {
                Button("取消", role: .cancel) {
                    cancelAction()
                }
                //            .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .padding()
                Spacer()
                Text("编辑")
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                Button("确定", role: .destructive) {
                    confirmAction()
                }
                .disabled(name.isEmpty)
                //            .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .padding()
            }
            Divider()
            Spacer().frame(height: 15)
            VStack(spacing: 0) {
                content
                    .frame(maxWidth: 200 ,maxHeight: 200)
                Spacer().frame(height: 15)
                Divider()
                Spacer().frame(height: 10)
                TextField("输入节点信息", text: $name)
                    .frame(maxWidth: 200)
                    .padding(.all, 10)
                    .background(Color(.tertiarySystemFill))
                    .cornerRadius(5) // 添加圆角
            }
            Spacer()
            //        .background(Color(.systemBackground))
            //        .cornerRadius(16)
            //        .popoverShadow(shadow: .system)
            //        .frame(width: 260)
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

