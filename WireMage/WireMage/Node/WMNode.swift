//
//  WMNode.swift
//  WireMage
//
//  Created by imengX on 17/05/2024.
//

import Foundation

protocol WMNodeEnvironment: Hashable {}

protocol WMNodeProtocol {
    var name: String { get }
    init(name: String)
}
