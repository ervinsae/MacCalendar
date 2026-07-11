//
//  CalendarView.swift
//  Menucal
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct CalendarView: View {
    @StateObject var calendarManager: CalendarManager
    var performSelection: (@escaping () -> Void) -> Void = { action in action() }

    @AppStorage("highlightedWeekdayMask") private var highlightedWeekdayMask: Int = SettingsManager.highlightedWeekdayMask

    @FocusState private var focusedField: DateField?

    enum DateField {
        case year
        case month
    }

    private let calendar = Calendar.Based

    private var columnCount: Int {
        SettingsManager.showWeekNumber ? 8 : 7
    }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(minimum: 21, maximum: 26), spacing: 0),
            count: columnCount
        )
    }

    private var highlightedColumnColor: Color {
        ItsycalPalette.primaryText.opacity(0.085)
    }

    private var monthTitle: String {
        DateHelper.formatDate(date: calendarManager.selectedMonth, format: "M月 yyyy")
    }

    private var selectedLunarDateTitle: String {
        LunarDateHelper.getLunarDateDisplay(for: calendarManager.selectedDay)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                header
                lunarDateHeader
            }
                .padding(.init(top: 10, leading: 12, bottom: 8, trailing: 12))

            VStack(spacing: 3) {
                weekdayHeader
                monthGrid
            }
            .padding(.init(top: 0, leading: 9, bottom: 5, trailing: 9))
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(monthTitle)
                .font(.system(size: 17.5, weight: .semibold, design: .rounded))
                .foregroundStyle(ItsycalPalette.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                MonthNavigationButton(systemName: "chevron.left") {
                    performSelection {
                        calendarManager.goToPreviousMonth()
                    }
                }

                Button {
                    performSelection {
                        calendarManager.resetToToday()
                    }
                } label: {
                    Circle()
                        .fill(isSelectedDayToday ? ItsycalPalette.secondaryText : Color(nsColor: .systemGreen))
                        .frame(width: 8, height: 8)
                }
                .buttonStyle(.plain)
                .help("回到今天")

                MonthNavigationButton(systemName: "chevron.right") {
                    performSelection {
                        calendarManager.goToNextMonth()
                    }
                }
            }
        }
        .frame(height: 18)
    }

    private var lunarDateHeader: some View {
        Text(selectedLunarDateTitle)
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(ItsycalPalette.secondaryText)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.init(top: 2, leading: 0, bottom: 2, trailing: 10))
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Array(calendarManager.weekdays.enumerated()), id: \.offset) { index, day in
                Text(weekdayDisplayName(day))
                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(isWeekendColumn(index) ? ItsycalPalette.secondaryText : ItsycalPalette.primaryText)
                    .frame(height: 18)
                    .frame(maxWidth: .infinity)
                    .background(columnHighlightBackground(isHighlightedColumn(index)))
            }
        }
    }

    private var monthGrid: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Array(calendarManager.calendarDays.enumerated()), id: \.element) { index, day in
                let columnIndex = index % columnCount

                if day.is_weekNumber {
                    Text("\(day.weekNumber ?? 0)")
                        .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(ItsycalPalette.secondaryText)
                        .frame(height: 35)
                        .frame(maxWidth: .infinity)
                } else {
                    CalendarDayCell(
                        day: day,
                        isSelected: isSelected(day),
                        calendar: calendar,
                        isHighlightedColumn: isHighlightedColumn(columnIndex),
                        highlightedColumnColor: highlightedColumnColor
                    ) {
                        if let date = day.date {
                            performSelection {
                                calendarManager.getSelectedDayEvents(date: date)
                            }
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }

    private var isSelectedDayToday: Bool {
        calendar.isDateInToday(calendarManager.selectedDay)
    }

    private func isSelected(_ day: CalendarDay) -> Bool {
        guard let date = day.date else { return false }
        return calendar.isDate(date, equalTo: calendarManager.selectedDay, toGranularity: .day)
    }

    private func weekdayDisplayName(_ value: String) -> String {
        switch value {
        case "周一": return "一"
        case "周二": return "二"
        case "周三": return "三"
        case "周四": return "四"
        case "周五": return "五"
        case "周六": return "六"
        case "周日": return "日"
        default: return value
        }
    }

    private func isWeekendColumn(_ index: Int) -> Bool {
        guard let weekday = weekdayValue(forColumnIndex: index) else { return false }
        return weekday == 1 || weekday == 7
    }

    private func isHighlightedColumn(_ index: Int) -> Bool {
        guard let weekday = weekdayValue(forColumnIndex: index) else { return false }
        let weekdayMask = 1 << (weekday - 1)
        return highlightedWeekdayMask & weekdayMask != 0
    }

    private func weekdayValue(forColumnIndex index: Int) -> Int? {
        let offset = SettingsManager.showWeekNumber ? index - 1 : index
        guard offset >= 0 else { return nil }

        if SettingsManager.firstDayInWeek == .monday {
            return ((offset + 1) % 7) + 1
        }
        return offset + 1
    }

    @ViewBuilder
    private func columnHighlightBackground(_ isHighlighted: Bool) -> some View {
        if isHighlighted {
            Rectangle()
                .fill(highlightedColumnColor)
        }
    }
}

private struct MonthNavigationButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundStyle(ItsycalPalette.secondaryText)
                .frame(width: 11, height: 15)
        }
        .buttonStyle(.plain)
    }
}

private struct CalendarDayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let calendar: Calendar
    let isHighlightedColumn: Bool
    let highlightedColumnColor: Color
    let action: () -> Void

    private var date: Date { day.date ?? Date() }
    private var dayNumber: Int { calendar.component(.day, from: date) }

    private var dayTextColor: Color {
        if !day.is_currentMonth { return ItsycalPalette.secondaryText.opacity(0.52) }
        return ItsycalPalette.primaryText
    }

    private var lunarText: String {
        if let holiday = day.holidays.first, !holiday.isEmpty { return holiday }
        if let solarTerm = day.solar_term, !solarTerm.isEmpty { return solarTerm }
        return day.short_lunar ?? ""
    }

    private var eventDots: [Color] {
        var colors = day.events.prefix(3).map { $0.color.color }
        if colors.isEmpty, !lunarText.isEmpty, day.is_currentMonth {
            if day.solar_term != nil {
                colors.append(ItsycalPalette.eventPurple)
            } else if !day.holidays.isEmpty {
                colors.append(ItsycalPalette.eventRed)
            }
        }
        return Array(colors.prefix(3))
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                columnHighlightBackground
                    .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35)

                VStack(spacing: 0) {
                    Text("\(dayNumber)")
                        .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(dayTextColor)
                        .lineLimit(1)

                    Text(lunarText)
                        .font(.system(size: 7.8, weight: .medium))
                        .foregroundStyle(day.is_currentMonth ? ItsycalPalette.secondaryText : ItsycalPalette.tertiaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .frame(height: 9)

                    HStack(spacing: 1.5) {
                        ForEach(Array(eventDots.enumerated()), id: \.offset) { _, color in
                            Circle()
                                .fill(color)
                                .frame(width: 3.0, height: 3.0)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.top, 4)
                .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35)
                .background(selectionBackground)
                .overlay(selectionStroke)
                .padding(.horizontal, 0.5)

                if let offday = day.offday {
                    Text(offday ? "休" : "班")
                        .font(.system(size: 5.5, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 8, height: 8)
                        .background(offday ? ItsycalPalette.eventRed : ItsycalPalette.secondaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 2.5, style: .continuous))
                        .offset(x: -1, y: 1)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var columnHighlightBackground: some View {
        if isHighlightedColumn {
            Rectangle()
                .fill(highlightedColumnColor)
        }
    }

    @ViewBuilder
    private var selectionBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(ItsycalPalette.selectionBlue.opacity(0.12))
        } else if day.is_today {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(ItsycalPalette.secondaryText.opacity(0.09))
        }
    }

    @ViewBuilder
    private var selectionStroke: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(ItsycalPalette.selectionBlue, lineWidth: 1.4)
        } else if day.is_today {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(ItsycalPalette.todayStroke, lineWidth: 1.2)
        }
    }
}

struct EditableDateComponent: View {
    @Binding var date: Date
    let component: Calendar.Component

    var calendarManager: CalendarManager

    @FocusState var focusState: CalendarView.DateField?
    let equals: CalendarView.DateField

    @State private var isEditing: Bool = false
    @State private var temporaryText: String = ""

    var body: some View {
        Group {
            if isEditing {
                TextField("输入", text: $temporaryText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .focused($focusState, equals: equals)
                    .onSubmit {
                        commitChange()
                    }
                    .onChange(of: focusState) { oldValue, newValue in
                        if newValue != equals {
                            commitChange()
                        }
                    }
            } else {
                Text(date, format: component == .year ? .dateTime.year() : .dateTime.month())
                    .contentShape(Rectangle())
                    .onTapGesture {
                        startEditing()
                    }
            }
        }
    }

    private func startEditing() {
        let value = Calendar.current.component(component, from: date)
        temporaryText = String(value)
        isEditing = true
        focusState = equals
    }

    private func commitChange() {
        let cleanText = temporaryText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let newValue = Int(cleanText) else {
            isEditing = false
            return
        }

        if component == .month {
            if !(1...12).contains(newValue) {
                isEditing = false
                return
            }
        }

        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        if component == .year {
            components.year = newValue
        } else if component == .month {
            components.month = newValue
        }

        if let newDate = Calendar.current.date(from: components) {
            let year = Calendar.current.component(.year, from: newDate)
            let month = Calendar.current.component(.month, from: newDate)

            calendarManager.goToCustomizeMonth(year: year, month: month)
        }

        isEditing = false
    }
}
