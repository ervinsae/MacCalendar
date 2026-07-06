//
//  EventListItemView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct EventListItemView: View {
    let event: CalendarEvent

    @State private var selectedEventId: String? = nil
    @State private var suppressNextOpenUntil: Date? = nil

    private var timeText: String {
        if event.isAllDay {
            return "全天"
        }

        return "\(DateHelper.formatDate(date: event.startDate, format: "HH:mm")) – \(DateHelper.formatDate(date: event.endDate, format: "HH:mm"))"
    }

    private var subtitleText: String? {
        let location = event.location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return location.isEmpty ? nil : location
    }

    private var isPastEvent: Bool {
        if event.isAllDay {
            return event.endDate < Calendar.Based.startOfDay(for: Date())
        }
        return event.endDate < Date()
    }

    private var titleColor: Color {
        isPastEvent ? ItsycalPalette.secondaryText : ItsycalPalette.primaryText
    }

    private var detailColor: Color {
        isPastEvent ? ItsycalPalette.secondaryText.opacity(0.78) : ItsycalPalette.secondaryText
    }

    private var dotColor: Color {
        isPastEvent ? ItsycalPalette.secondaryText.opacity(0.45) : event.color.color
    }

    private func handleTap() {
        if selectedEventId == event.id {
            suppressNextOpenUntil = nil
            selectedEventId = nil
            return
        }

        if let suppressNextOpenUntil, suppressNextOpenUntil > Date() {
            self.suppressNextOpenUntil = nil
            return
        }

        selectedEventId = event.id
    }

    private func markDismissedByPopoverIfNeeded() {
        if selectedEventId == event.id {
            suppressNextOpenUntil = Date().addingTimeInterval(0.35)
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
                .padding(.top, 3)

            VStack(alignment: .leading, spacing: 1) {
                Text(event.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(titleColor)
                    .lineLimit(1)

                if let subtitleText {
                    Text(subtitleText)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(detailColor)
                        .lineLimit(1)
                }

                Text(timeText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(detailColor)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 0)
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .popover(
            isPresented: Binding(
                get: { selectedEventId == event.id },
                set: { isPresented in
                    if !isPresented {
                        markDismissedByPopoverIfNeeded()
                        selectedEventId = nil
                    }
                }
            ),
            attachmentAnchor: .rect(.rect(CGRect(x: -10, y: 20, width: 0, height: 0))),
            arrowEdge: .leading,
            content: {
                EventDetailView(event: event)
            }
        )
    }
}
