//
//  EventListView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct EventListView: View {
    @StateObject var calendarManager: CalendarManager

    private let calendar = Calendar.Based

    static func estimatedHeight(calendarManager: CalendarManager) -> CGFloat {
        let calendar = Calendar.Based
        let selectedDay = calendarManager.selectedDay
        let selectedNote = calendarNote(for: calendarDay(for: selectedDay, in: calendarManager.calendarDays))
        let selectedEvents = visibleEvents(calendarManager.selectedDayEvents, excludingAllDayTitle: selectedNote?.text)

        var sections: [(note: ItsycalCalendarNote?, events: [CalendarEvent], isEmptyVisibleSection: Bool)] = [
            (selectedNote, selectedEvents, selectedEvents.isEmpty && selectedNote == nil)
        ]

        if let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: selectedDay)),
           let day = calendarDay(for: nextDay, in: calendarManager.calendarDays) {
            let note = calendarNote(for: day)
            let events = visibleEvents(day.events, excludingAllDayTitle: note?.text)
            if !events.isEmpty || note != nil {
                sections.append((note, events, false))
            }
        }

        let toolbarHeight: CGFloat = 28
        let dividerHeight: CGFloat = 1
        let contentPadding: CGFloat = 4 + 4
        let sectionGap: CGFloat = max(0, CGFloat(sections.count - 1)) * 11
        let sectionHeights = sections.reduce(CGFloat(0)) { total, section in
            total + estimatedSectionHeight(note: section.note, events: section.events, isEmptyVisibleSection: section.isEmptyVisibleSection)
        }

        return toolbarHeight + dividerHeight + contentPadding + sectionGap + sectionHeights
    }

    private static func estimatedSectionHeight(
        note: ItsycalCalendarNote?,
        events: [CalendarEvent],
        isEmptyVisibleSection: Bool
    ) -> CGFloat {
        var height: CGFloat = 16
        if note != nil {
            height += 4 + 15
        }
        if isEmptyVisibleSection {
            height += 7 + 15
        }
        if !events.isEmpty {
            height += 4
            height += events.reduce(CGFloat(0)) { total, event in
                total + estimatedEventHeight(event)
            }
        }
        return height
    }

    private static func estimatedEventHeight(_ event: CalendarEvent) -> CGFloat {
        let location = event.location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return location.isEmpty ? 30 : 43
    }

    private static func visibleEvents(_ events: [CalendarEvent], excludingAllDayTitle title: String? = nil) -> [CalendarEvent] {
        events.filter { event in
            guard !event.id.hasPrefix("days-indicator-") else { return false }
            guard let title else { return true }
            return !(event.isAllDay && event.title == title)
        }
    }

    private static func calendarDay(for date: Date, in days: [CalendarDay]) -> CalendarDay? {
        days.first { day in
            guard !day.is_weekNumber, let dayDate = day.date else { return false }
            return Calendar.Based.isDate(dayDate, inSameDayAs: date)
        }
    }

    private static func calendarNote(for day: CalendarDay?) -> ItsycalCalendarNote? {
        guard let day else { return nil }
        if let solarTerm = day.solar_term, !solarTerm.isEmpty {
            return ItsycalCalendarNote(text: solarTerm, color: ItsycalPalette.eventPurple)
        }
        if let holiday = day.holidays.first, !holiday.isEmpty {
            return ItsycalCalendarNote(text: holiday, color: ItsycalPalette.eventRed)
        }
        return nil
    }

    private var eventSections: [ItsycalEventSection] {
        var sections: [ItsycalEventSection] = [
            section(for: calendarManager.selectedDay, events: visibleEvents(calendarManager.selectedDayEvents, excludingAllDayTitle: calendarNote(for: calendarDay(for: calendarManager.selectedDay))?.text))
        ]

        if let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: calendarManager.selectedDay)),
           let nextSection = optionalSection(for: nextDay) {
            sections.append(nextSection)
        }

        return sections
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar

            Divider()
                .overlay(ItsycalPalette.separator)
                .padding(.horizontal, 9)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(eventSections.enumerated()), id: \.element.id) { index, section in
                    if index > 0 {
                        Divider()
                            .overlay(ItsycalPalette.separator)
                            .padding(.vertical, 5)
                    }

                    EventSectionView(section: section)
                }
            }
            .padding(.horizontal, 11)
            .padding(.top, 4)
            .padding(.bottom, 4)
        }
    }

    private var toolbar: some View {
        HStack(spacing: 0) {
            ItsycalToolbarButton(systemName: "plus", size: 15.5, help: "新增事件") {
                AppDelegate.shared?.openNewEventWindow()
            }
            Spacer()
            ItsycalToolbarButton(systemName: "pin.fill", size: 11, help: "固定弹窗") {}
            Spacer().frame(width: 10)
            ItsycalToolbarButton(systemName: "calendar", size: 13, help: "打开系统日历") {
                AppDelegate.shared?.openSystemCalendar()
            }
            Spacer().frame(width: 10)
            ItsycalToolbarButton(systemName: "gearshape.fill", size: 13.5, help: "日历设置") {
                AppDelegate.shared?.showSettingsWindowWithSelection(.calendar)
            }
        }
        .foregroundStyle(ItsycalPalette.secondaryText)
        .frame(height: 25)
        .padding(.horizontal, 11)
        .padding(.bottom, 2)
    }

    private func section(for date: Date, events: [CalendarEvent]) -> ItsycalEventSection {
        let day = calendarDay(for: date)
        return ItsycalEventSection(
            date: date,
            title: relativeTitle(for: date),
            dateText: DateHelper.formatDate(date: date, format: "M月d日"),
            note: calendarNote(for: day),
            events: events
        )
    }

    private func optionalSection(for date: Date) -> ItsycalEventSection? {
        guard let day = calendarDay(for: date) else { return nil }
        let note = calendarNote(for: day)
        guard !day.events.isEmpty || note != nil else { return nil }
        return ItsycalEventSection(
            date: date,
            title: relativeTitle(for: date),
            dateText: DateHelper.formatDate(date: date, format: "M月d日"),
            note: note,
            events: visibleEvents(day.events, excludingAllDayTitle: note?.text)
        )
    }

    private func visibleEvents(_ events: [CalendarEvent], excludingAllDayTitle title: String? = nil) -> [CalendarEvent] {
        events.filter { event in
            guard !event.id.hasPrefix("days-indicator-") else { return false }
            guard let title else { return true }
            return !(event.isAllDay && event.title == title)
        }
    }

    private func calendarDay(for date: Date) -> CalendarDay? {
        calendarManager.calendarDays.first { day in
            guard !day.is_weekNumber, let dayDate = day.date else { return false }
            return calendar.isDate(dayDate, inSameDayAs: date)
        }
    }

    private func calendarNote(for day: CalendarDay?) -> ItsycalCalendarNote? {
        guard let day else { return nil }
        if let solarTerm = day.solar_term, !solarTerm.isEmpty {
            return ItsycalCalendarNote(text: solarTerm, color: ItsycalPalette.eventPurple)
        }
        if let holiday = day.holidays.first, !holiday.isEmpty {
            return ItsycalCalendarNote(text: holiday, color: ItsycalPalette.eventRed)
        }
        return nil
    }

    private func relativeTitle(for date: Date) -> String {
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfDate = calendar.startOfDay(for: date)
        let dayOffset = calendar.dateComponents([.day], from: startOfToday, to: startOfDate).day

        switch dayOffset {
        case 0:
            return "今天"
        case 1:
            return "明天"
        case 2:
            return "后天"
        default:
            return DateHelper.formatDate(date: date, format: "EEEE")
        }
    }
}

private struct ItsycalEventSection: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let dateText: String
    let note: ItsycalCalendarNote?
    let events: [CalendarEvent]
}

private struct ItsycalCalendarNote {
    let text: String
    let color: Color
}

private struct EventSectionView: View {
    let section: ItsycalEventSection

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(section.title)
                    .font(.system(size: 12.5, weight: .bold, design: .rounded))
                    .foregroundStyle(ItsycalPalette.primaryText)

                Spacer()

                Text(section.dateText)
                    .font(.system(size: 11.5, weight: .bold, design: .rounded))
                    .foregroundStyle(ItsycalPalette.secondaryText)
            }

            if let note = section.note {
                ItsycalCalendarNoteRow(note: note)
                    .padding(.top, 4)
            }

            if section.events.isEmpty {
                if section.note == nil {
                    emptyState
                        .padding(.top, 7)
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(section.events, id: \.id) { event in
                        EventListItemView(event: event)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private var emptyState: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(ItsycalPalette.secondaryText.opacity(0.45))
                .frame(width: 5, height: 5)
                .padding(.top, 4)

            Text("今天无日程")
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(ItsycalPalette.secondaryText)
        }
    }
}

private struct ItsycalCalendarNoteRow: View {
    let note: ItsycalCalendarNote

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(note.color)
                .frame(width: 5, height: 14)

            Text(note.text)
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(ItsycalPalette.primaryText)
                .lineLimit(1)
        }
    }
}

private struct ItsycalToolbarButton: View {
    let systemName: String
    let size: CGFloat
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .frame(width: 22, height: 22)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
