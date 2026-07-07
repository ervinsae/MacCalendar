//
//  EventDetailCard.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct EventDetailView: View {
    @ObservedObject var calendarManager: CalendarManager
    let event: CalendarEvent

    @State private var showingDeleteConfirmation = false
    @State private var showingDeleteError = false
    @State private var deleteErrorMessage = ""

    private var visibleAttendees: [CalendarEventPerson] {
        event.attendees?.filter { !personDisplayName($0).isEmpty } ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Image(systemName: "clock")
                    .frame(width: 20)
                    .scaledToFit()
                Text(DateHelper.formatDate(date: event.startDate, format: "yyyy/MM/dd"))
                if event.isAllDay {
                    Text("全天")
                } else {
                    HStack(spacing: 0) {
                        Text(DateHelper.formatDate(date: event.startDate, format: "HH:mm"))
                        Text("-")
                        Text(DateHelper.formatDate(date: event.endDate, format: "HH:mm"))
                        if let timespan = DateHelper.formattedDuration(from: event.startDate, to: event.endDate) {
                            Text("（\(timespan)）")
                        }
                    }
                }

                Spacer()

                Button(action: {
                    AppDelegate.shared?.openEventEditWindow(event: event)
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(.blue)
                }

                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(ItsycalPalette.primaryText)

            if let location = cleanText(event.location), !location.isEmpty {
                DetailRow(systemName: "location") {
                    LinkedDetailText(text: location)
                }
            }

            if let organizer = event.organizer {
                let name = personDisplayName(organizer)
                if !name.isEmpty {
                    DetailRow(systemName: "person") {
                        Text(name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(ItsycalPalette.primaryText)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }

            if !visibleAttendees.isEmpty {
                DetailRow(systemName: "person.2") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(visibleAttendees.enumerated()), id: \.offset) { _, attendee in
                            HStack(alignment: .center, spacing: 6) {
                                Circle()
                                    .fill(attendeeStatusColor(attendee))
                                    .frame(width: 5, height: 5)

                                Text(personDisplayName(attendee))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(attendeeTextColor(attendee))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
            }

            Divider()

            if let notes = cleanText(event.notes), !notes.isEmpty {
                ScrollView {
                    LinkedDetailText(text: notes)
                        .frame(minHeight: 50, alignment: .topLeading)
                }
                .frame(maxHeight: 500)
            } else {
                Spacer(minLength: 50)
            }

            if let eventURL = event.url {
                let url = UrlHelper.normalizeURL(from: eventURL)
                HStack {
                    Image(systemName: "link")
                    Link(url.absoluteString, destination: url)
                        .foregroundStyle(ItsycalPalette.selectionBlue)
                        .underline()
                }
                .font(.system(size: 11, weight: .medium))
            }
        }
        .padding()
        .frame(width: 350)
        .foregroundStyle(ItsycalPalette.primaryText)
        .background(ItsycalPalette.windowBackground)
        .presentationBackground(ItsycalPalette.windowBackground)
        .alert("确认删除", isPresented: $showingDeleteConfirmation) {
            Button("删除", role: .destructive) {
                Task {
                    do {
                        try await calendarManager.deleteEvent(withId: event.id)
                    } catch {
                        deleteErrorMessage = error.localizedDescription
                        showingDeleteError = true
                    }
                }
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("确定要删除事件“\(event.title)”吗？此操作无法撤销。")
        }
        .alert("删除失败", isPresented: $showingDeleteError) {
            Button("好的", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage)
        }
    }

    private func attendeeTextColor(_ person: CalendarEventPerson) -> Color {
        person.status == .accepted ? ItsycalPalette.primaryText : ItsycalPalette.secondaryText
    }

    private func attendeeStatusColor(_ person: CalendarEventPerson) -> Color {
        switch person.status {
        case .accepted:
            return Color(nsColor: .systemGreen)
        case .declined:
            return ItsycalPalette.eventRed
        case .tentative, .unknown, .pending, .delegated, .completed, .inProcess, nil:
            return ItsycalPalette.secondaryText.opacity(0.65)
        }
    }

    private func personDisplayName(_ person: CalendarEventPerson) -> String {
        let name = person.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !name.isEmpty { return name }

        guard let url = person.url else { return "" }
        return url.lastPathComponent.isEmpty ? url.absoluteString : url.lastPathComponent
    }

    private func cleanText(_ text: String?) -> String? {
        let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

private struct DetailRow<Content: View>: View {
    let systemName: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: systemName)
                .frame(width: 20)
                .scaledToFit()
                .foregroundStyle(ItsycalPalette.secondaryText)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct LinkedDetailText: View {
    let text: String

    private var parts: [LinkedDetailTextPart] {
        LinkedDetailTextPart.parts(from: text)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                switch part {
                case .plain(let value):
                    Text(value)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(ItsycalPalette.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                case .link(let display, let url):
                    Link(display, destination: url)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(ItsycalPalette.selectionBlue)
                        .underline()
                }
            }
        }
    }
}

private enum LinkedDetailTextPart {
    case plain(String)
    case link(String, URL)

    static func parts(from text: String) -> [LinkedDetailTextPart] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return text.split(whereSeparator: \.isNewline).map { .plain(String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
        }

        var result: [LinkedDetailTextPart] = []
        let lines = text.split(whereSeparator: \.isNewline).map(String.init)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else { continue }

            let nsText = trimmedLine as NSString
            let matches = detector.matches(in: trimmedLine, options: [], range: NSRange(location: 0, length: nsText.length))
            guard !matches.isEmpty else {
                result.append(.plain(trimmedLine))
                continue
            }

            var cursor = 0
            for match in matches {
                if match.range.location > cursor {
                    let plain = nsText.substring(with: NSRange(location: cursor, length: match.range.location - cursor))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !plain.isEmpty { result.append(.plain(plain)) }
                }

                let display = nsText.substring(with: match.range)
                if let url = match.url {
                    result.append(.link(display, UrlHelper.normalizeURL(from: url)))
                } else if let url = URL(string: display) {
                    result.append(.link(display, UrlHelper.normalizeURL(from: url)))
                } else {
                    result.append(.plain(display))
                }

                cursor = match.range.location + match.range.length
            }

            if cursor < nsText.length {
                let plain = nsText.substring(with: NSRange(location: cursor, length: nsText.length - cursor))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !plain.isEmpty { result.append(.plain(plain)) }
            }
        }

        return result
    }
}
