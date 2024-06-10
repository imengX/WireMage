//
//  CarControlNode.swift
//  WireMage
//
//  Created by imengX on 10/6/24.
//

import Foundation
import SwiftUI

class CarControlNode: ProcessingBasicNode, FlowNodePortProtocol {
    enum Signal: String {
        case go, back, left, right, stop
        case ledon, ledoff

        init?(polarValue: PolarValue) {
            if polarValue.radius == 0 {
                self = .stop
            } else {
                switch polarValue.direction() {
                case .up:
                    self = .go
                case .down:
                    self = .back
                case .left:
                    self = .left
                case .right:
                    self = .right
                case .none:
                    self = .stop
                }
            }
        }
    }

    lazy var inputs: [FlowPort] = [polar, go, back, left, right, ledOn, ledOff]

    let polar = FlowPort(name: "极坐标", type: .polarValue)

    let go = FlowPort(name: "前进", type: .signal)
    let back = FlowPort(name: "后退", type: .signal)
    let left = FlowPort(name: "左转", type: .signal)
    let right = FlowPort(name: "右转", type: .signal)
    let stop = FlowPort(name: "停止", type: .signal)
    let ledOn = FlowPort(name: "开灯", type: .signal)
    let ledOff = FlowPort(name: "关灯", type: .signal)

    let outputs: [FlowPort] = []

    override func handlePackage(pipelinePackage: PipelinePackage) async {
        let port = inputs[pipelinePackage.wire.input.portIndex]
        switch port {
        case polar:
            guard let data = pipelinePackage.data as? PolarValue else { return }
            await sendSignal(Signal(polarValue: data))
        case go:
            await sendSignal(.go)
        case back:
            await sendSignal(.back)
        case left:
            await sendSignal(.left)
        case right:
            await sendSignal(.right)
        case stop:
            await sendSignal(.stop)
        case ledOn:
            await sendSignal(.ledon)
        case ledOff:
            await sendSignal(.ledoff)
        default: break
        }
    }

    var isSendingSignal = false

    func sendSignal(_ signal: Signal?) async {
        if isSendingSignal && signal != .stop {
            return
        }
        
        guard let action = signal?.rawValue else { return }

        isSendingSignal = true
        await sendRequest(action: action)
        isSendingSignal = false

        @Sendable func sendRequest(action: String) async {
            print(action)
            return
            let timeIntervalSince1970 = Int(Date().timeIntervalSince1970 * 1000)
//            print("1718004513642\n", timeIntervalSince1970)

            guard let url = URL(string: "http://\("192.168.1.9"):80/\(action)?\(timeIntervalSince1970)") else {
//            guard let url = URL(string: "http://192.168.1.12:81/\(action)") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            do {
                let response = try await URLSession.shared.data(for: request)
                guard let httpResponse = response.1 as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }

//                print("Response status code: \(httpResponse.statusCode)")
            } catch {
                print(error)
            }
        }
    }
}

// 定义枚举表示方向
enum Direction {
    case up, down, left, right, none
}

// 定义极坐标类
extension PolarValue {
//    var radius: Float // 半径
//    var angle: Float // 角度

//    // 初始化方法
//    init(radius: Float, angle: Float) {
//        self.radius = radius
//        self.angle = angle
//    }

    // 方法：根据极坐标计算点的方向
    func direction() -> Direction {
        print(angle)
        switch angle {
        case Angle(degrees: 135)..<Angle(degrees: 225):
            return .up
        case Angle(degrees: 45)..<Angle(degrees: 135):
            return .left
        case Angle(degrees: 225)..<Angle(degrees: 315):
            return .right
        case Angle(degrees: 315)...Angle(degrees: 360), Angle(degrees: 0)...Angle(degrees: 45):
            return .down
        default: return .none
        }
//        switch Angle.zero ... Angle(degrees: 360) {
//        default:

//        }

        // 根据角度在圆的哪个区域来判断方向
//        if angleInRadians >= translfromAngle && angleInRadians < translfromAngle + dAngle  {
//            // 上方
//            return .up
//        } else if angleInRadians >= translfromAngle * 3 && angleInRadians < translfromAngle * 5 {
//            // 左方
//            return .left
//        } else if angleInRadians >= 5 * Float.pi / 4 && angleInRadians < 7 * Float.pi / 4 {
//            // 下方
//            return .down
//        } else {
//            // 右方
//            return .right
//        }
    }
}
//// 定义笛卡尔坐标系转换类
//class CartesianCoordinateConverter {
//
//    // 方法：将x和y转换为极坐标
//    static func convertToPolar(x: Float, y: Float) -> PolarValue {
//        // 计算半径
//        let radius = sqrt(x * x + y * y)
//
//        // 计算角度
//        let angle = atan2(y, x) * 180 / Float.pi
//
//        // 返回极坐标
//        return PolarValue(radius: radius, angle: angle)
//    }
//
//}
