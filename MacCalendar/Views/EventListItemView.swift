//
//  EventListItemView.swift
//  Menucal
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI
import AppKit

struct EventListItemView: View {
    let event: CalendarEvent
    @ObservedObject var calendarManager: CalendarManager

    @State private var anchorBox = EventDetailPopoverAnchorBox()
    @State private var isHovering = false

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
        AppDelegate.shared?.toggleEventDetailPopover(
            event: event,
            relativeTo: anchorBox.view
        )
    }

    @ViewBuilder
    private var hoverBackground: some View {
        if isHovering {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(ItsycalPalette.secondaryText.opacity(0.11))
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
        .padding(.vertical, 3)
        .padding(.horizontal, 5)
        .background(hoverBackground)
        .background {
            EventDetailPopoverAnchor(box: anchorBox)
        }
        .contentShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            handleTap()
        }
    }
}
