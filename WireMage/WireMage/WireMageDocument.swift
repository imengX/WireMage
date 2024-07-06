//
//  WireMageDocument.swift
//  WireMage
//
//  Created by imengX on 14/05/2024.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "com.example.plain-text")
    }
}

struct WireMageDocument: FileDocument {
    var data: NodeSpace

    static var readableContentTypes: [UTType] { [.json] }

    init(configuration: ReadConfiguration) throws {
        guard
            let data = configuration.file.regularFileContents
        else { throw NSError() }
        self.data = try JSONDecoder().decode(NodeSpace.self, from: data)
    }

    init(data: NodeSpace) {
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let contents = try JSONEncoder().encode(data)
        return FileWrapper(regularFileWithContents: contents)
    }
}

struct JsonDocument: FileDocument {

    static var readableContentTypes: [UTType] { [.json] }
    var json: Data

    init(configuration: ReadConfiguration) throws {
        guard
            let data = configuration.file.regularFileContents
        else { throw NSError() }
        self.json = data
    }

    init(json: Data) {
        self.json = json
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: self.json)
    }
}
