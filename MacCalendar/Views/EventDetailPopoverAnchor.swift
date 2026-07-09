//
//  EventDetailPopoverAnchor.swift
//  Menucal
//
//  Created by Codex on 2026/7/8.
//

import SwiftUI
import AppKit

final class EventDetailPopoverAnchorBox {
    weak var view: NSView?
}

struct EventDetailPopoverAnchor: NSViewRepresentable {
    let box: EventDetailPopoverAnchorBox

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        box.view = view
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        box.view = nsView
    }
}
