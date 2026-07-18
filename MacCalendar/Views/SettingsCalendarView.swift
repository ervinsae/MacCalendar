//
//  SettingsCalendarView.swift
//  Menucal
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI
import EventKit

struct SettingsCalendarView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var isRequestingAccess = false
    
    var body: some View {
        Form {
            authorizationContent
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await refreshCalendarAccess()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task {
                await refreshCalendarAccess()
            }
        }
    }

    @ViewBuilder
    private var authorizationContent: some View {
        if calendarManager.hasCalendarAccess {
            calendarContent
        } else {
            switch calendarManager.authorizationStatus {
            case .notDetermined:
                permissionSection(
                    icon: "calendar.badge.plus",
                    title: "允许访问日历",
                    message: "Menucal 需要读取日历，才能显示和管理你的日程。",
                    actionTitle: "允许日历访问",
                    actionIcon: "lock.open"
                ) {
                    requestCalendarAccess()
                }
            case .denied:
                permissionSection(
                    icon: "lock.fill",
                    title: "日历访问已关闭",
                    message: "请在系统设置的隐私与安全性中，允许 Menucal 完全访问日历。",
                    actionTitle: "打开系统设置",
                    actionIcon: "gear"
                ) {
                    openCalendarPrivacySettings()
                }
            case .restricted:
                permissionSection(
                    icon: "lock.trianglebadge.exclamationmark",
                    title: "日历访问受限",
                    message: "当前系统策略限制了日历访问，请检查系统设置或设备管理策略。",
                    actionTitle: "打开系统设置",
                    actionIcon: "gear"
                ) {
                    openCalendarPrivacySettings()
                }
            default:
                if #available(macOS 14.0, *),
                   calendarManager.authorizationStatus == .writeOnly {
                    permissionSection(
                        icon: "calendar.badge.exclamationmark",
                        title: "需要完整日历访问权限",
                        message: "Menucal 当前只能添加事件，无法读取并显示已有日程。请改为允许完全访问。",
                        actionTitle: "打开系统设置",
                        actionIcon: "gear"
                    ) {
                        openCalendarPrivacySettings()
                    }
                } else {
                    permissionSection(
                        icon: "calendar.badge.exclamationmark",
                        title: "无法访问日历",
                        message: "请前往系统设置检查 Menucal 的日历访问权限。",
                        actionTitle: "打开系统设置",
                        actionIcon: "gear"
                    ) {
                        openCalendarPrivacySettings()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var calendarContent: some View {
        if calendarManager.calendarInfos.isEmpty {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("未找到可用日历")
                        .font(.headline)
                    Text("请先在系统日历中创建日历，然后返回此页面重新加载。")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    HStack(spacing: 10) {
                        Button {
                            AppDelegate.shared?.openSystemCalendar()
                        } label: {
                            Label("打开系统日历", systemImage: "calendar")
                        }
                        Button {
                            requestCalendarAccess()
                        } label: {
                            Label("重新加载", systemImage: "arrow.clockwise")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        } else {
            Section {
                ForEach(calendarManager.calendarInfos) { calendar in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(calendar.color)
                            .frame(width: 12, height: 12)
                        Text(calendar.title)
                            .font(.body)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { calendar.isSelected },
                            set: { isOn in
                                if let index = calendarManager.calendarInfos.firstIndex(where: { $0.id == calendar.id }) {
                                    calendarManager.calendarInfos[index].isSelected = isOn
                                }
                            }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                    }
                }
            }
        }
    }

    private func permissionSection(
        icon: String,
        title: String,
        message: String,
        actionTitle: String,
        actionIcon: String,
        action: @escaping () -> Void
    ) -> some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                if isRequestingAccess {
                    ProgressView("等待系统授权…")
                        .controlSize(.small)
                } else {
                    Button(action: action) {
                        Label(actionTitle, systemImage: actionIcon)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    private func requestCalendarAccess() {
        Task {
            await refreshCalendarAccess()
        }
    }

    @MainActor
    private func refreshCalendarAccess() async {
        guard !isRequestingAccess else { return }
        isRequestingAccess = true
        defer { isRequestingAccess = false }

        await calendarManager.requestAccessIfNeeded()
        if calendarManager.hasCalendarAccess {
            await calendarManager.loadCalendarInfo()
        }
    }

    private func openCalendarPrivacySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
