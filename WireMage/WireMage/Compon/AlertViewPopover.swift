//
//  AlertViewPopover.swift
//  WireMage
//
//  Created by imengX on 5/6/24.
//

import SwiftUI

//public enum Templates {
//    /// Highlight color for the alert and menu buttons.
//    public static var buttonHighlightColor = Color.secondary.opacity(0.2)
//}
//
//public extension Templates {
//    /// A button style to resemble that of a system alert.
//    struct AlertButtonStyle: ButtonStyle {
//        /// A button style to resemble that of a system alert.
//        public init() {}
//        public func makeBody(configuration: Configuration) -> some View {
//            configuration.label
//                .frame(maxWidth: .infinity)
//                .contentShape(Rectangle())
//                .padding()
//                .background(
//                    configuration.isPressed ? Templates.buttonHighlightColor : Color.clear
//                )
//        }
//    }
//}

//struct AlertViewPopover<Content>: View where Content : View {
//    @Binding var present: Bool
////    @Binding var expanding: Bool
//
//    /// the initial animation
//    @State var scaled = true
//    private var content: () -> Content
//
//    @inlinable public init(present: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
//        self._present = present
//        self.content = content
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            content()
////            VStack(spacing: 6) {
////                Text("Alert!")
////                    .fontWeight(.medium)
////                    .multilineTextAlignment(.center)
////
////                Text("Popovers has used your location 2000 times in the past 7 days.")
////                    .multilineTextAlignment(.center)
////            }
////            .padding()
////
////            Divider()
////
////            Button {
////                present = false
////            } label: {
////                Text("Ok")
////                    .foregroundColor(.blue)
////            }
////            .buttonStyle(Templates.AlertButtonStyle())
//        }
//        .background(Color(.systemBackground))
//        .cornerRadius(16)
//        .popoverShadow(shadow: .system)
//        .frame(width: 260)
////        .scaleEffect(expanding ? 1.05 : 1)
//        .scaleEffect(scaled ? 2 : 1)
//        .opacity(scaled ? 0 : 1)
//        .onAppear {
//            withAnimation(.spring(
//                response: 0.4,
//                dampingFraction: 0.9,
//                blendDuration: 1
//            )) {
//                scaled = false
//            }
//        }
//    }
//}

import Popovers

//extension View {
//    func popoverAlert<MainContent: View, BackgroundContent: View>(
//        present: Binding<Bool>,
//        attributes buildAttributes: @escaping ((inout Popover.Attributes) -> Void) = {
//            $0.blocksBackgroundTouches = true
//            $0.rubberBandingMode = .none
//            $0.position = .relative(
//                popoverAnchors: [
//                    .center,
//                ]
//            )
//            $0.presentation.animation = .easeOut(duration: 0.15)
//            $0.dismissal.mode = .none
//            //            $0.onTapOutside = {
//            //                withAnimation(.easeIn(duration: 0.15)) {
//            //                    expanding = true
//            //                }
//            //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            //                    withAnimation(.easeOut(duration: 0.4)) {
//            //                        expanding = false
//            //                    }
//            //                }
//            //            }
//        },
//        @ViewBuilder view: @escaping () -> MainContent,
//        @ViewBuilder background: @escaping () -> BackgroundContent = { EmptyView() }
//    ) -> some View {
//        return popover(
//            present: present,
//            attributes: buildAttributes,
//            view: view,
//            background: background
//        )
//    }
//}
