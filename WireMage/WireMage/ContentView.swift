//
//  ContentView.swift
//  WireMage
//
//  Created by imengX on 14/05/2024.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: WireMageDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(WireMageDocument()))
}
