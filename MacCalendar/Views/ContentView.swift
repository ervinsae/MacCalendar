//
//  ContentView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct ContentView: View {
    @StateObject var calendarManager: CalendarManager
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = SettingsManager.appearanceMode
    @State private var presentedEventId: String? = nil

    static func preferredSize(calendarManager: CalendarManager) -> CGSize {
        CGSize(
            width: contentWidth,
            height: calendarHeight(calendarManager: calendarManager) + EventListView.estimatedHeight(calendarManager: calendarManager)
        )
    }

    private static var contentWidth: CGFloat {
        SettingsManager.showWeekNumber ? 210 : 196
    }

    private static func calendarHeight(calendarManager: CalendarManager) -> CGFloat {
        let columnCount = SettingsManager.showWeekNumber ? 8 : 7
        let dayCount = max(calendarManager.calendarDays.count, columnCount * 6)
        let rowCount = CGFloat((dayCount + columnCount - 1) / columnCount)
        return 8 + 18 + 3 + 18 + 3 + rowCount * 35 + 5
    }

    private func performAfterDismissingEventPopover(_ action: @escaping () -> Void) {
        presentedEventId = nil
        action()
    }

    var body: some View {
        VStack(spacing: 0) {
            CalendarView(calendarManager: calendarManager, performSelection: performAfterDismissingEventPopover)
            EventListView(calendarManager: calendarManager, presentedEventId: $presentedEventId)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: Self.contentWidth)
        .fixedSize(horizontal: true, vertical: true)
        .background(ItsycalPalette.windowBackground)
        .clipShape(RoundedRectangle(cornerRadius: ItsycalPalette.popoverCornerRadius, style: .continuous))
        .onChange(of: calendarManager.selectedDay) { _, _ in
            presentedEventId = nil
        }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizeKey.self, value: proxy.size)
            }
        }
    }
}

enum ItsycalPalette {
    static let windowBackground = Color(nsColor: .windowBackgroundColor)
    static let primaryText = Color(nsColor: .labelColor)
    static let secondaryText = Color(nsColor: .secondaryLabelColor)
    static let tertiaryText = Color(nsColor: .tertiaryLabelColor)
    static let separator = Color(nsColor: .separatorColor).opacity(0.55)
    static let selectionBlue = Color(nsColor: .systemBlue)
    static let todayStroke = Color(nsColor: .tertiaryLabelColor)
    static let eventRed = Color(nsColor: .systemRed)
    static let eventBlue = Color(nsColor: .systemBlue)
    static let eventPurple = Color(nsColor: .systemPurple)
    static let popoverCornerRadius: CGFloat = 6
}

struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
