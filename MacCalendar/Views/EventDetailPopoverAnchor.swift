//
//  EventDetailPopoverAnchor.swift
//  MacCalendar
//
//  Created by Codex on 2026/7/8.
//

import SwiftUI
import AppKit

struct EventDetailPopoverAnchor: NSViewRepresentable {
    let onResolve: (NSView) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            onResolve(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            onResolve(nsView)
        }
    }
}
