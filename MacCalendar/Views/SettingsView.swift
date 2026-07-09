//
//  SettingsView.swift
//  Menucal
//
//  Created by ruihelin on 2025/10/6.
//

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
            List(SettingsType.allCases, selection: $selection) { setting in
                Label(setting.rawValue, systemImage: setting.icon)
                    .tag(setting)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 200)
        } detail: {
            selection.view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(calendarManager)
                .navigationTitle(selection.rawValue)
        }
    }
}
