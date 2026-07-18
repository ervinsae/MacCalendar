//
//  SettingsView.swift
//  Menucal
//
//  Created by ruihelin on 2025/10/6.
//

import AppKit
import SwiftUI

struct SettingsView: View {
    @State private var selection: SettingsType
    @ObservedObject var calendarManager: CalendarManager
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = SettingsManager.appearanceMode

    init(calendarManager: CalendarManager, initialSelection: SettingsType = .customized) {
        self.calendarManager = calendarManager
        self._selection = State(initialValue: initialSelection)
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(SettingsType.allCases, selection: $selection) { setting in
                    Label(setting.rawValue, systemImage: setting.icon)
                        .tag(setting)
                }
                .listStyle(.sidebar)

                SettingsBrandFooter()
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 200)
        } detail: {
            selection.view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(calendarManager)
                .navigationTitle(selection.rawValue)
        }
    }
}

private struct SettingsBrandFooter: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .opacity(0.45)

            HStack(spacing: 8) {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Menucal")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)

                    Text("v\(Bundle.main.appVersion ?? "-")")
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Menucal")
    }
}
