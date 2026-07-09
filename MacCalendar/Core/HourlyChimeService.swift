//
//  HourlyChimeService.swift
//  Menucal
//
//  Created by Codex on 2026/7/7.
//

import AVFoundation
import Foundation

final class HourlyChimeService: NSObject {
    private let calendar: Calendar
    private var timer: Timer?
    private var player: AVAudioPlayer?
    private var lastPlayedHour: Date?

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        super.init()
    }

    deinit {
        stop()
    }

    func start() {
        scheduleNextChime(after: Date())
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        player?.stop()
        player = nil
    }

    private func scheduleNextChime(after date: Date) {
        timer?.invalidate()

        guard let nextHour = nextWholeHour(after: date) else {
            return
        }

        let timer = Timer(
            fireAt: nextHour,
            interval: 0,
            target: self,
            selector: #selector(handleTimer),
            userInfo: nil,
            repeats: false
        )
        timer.tolerance = 0.5
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func nextWholeHour(after date: Date) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        components.minute = 0
        components.second = 0
        components.nanosecond = 0

        guard let hourStart = calendar.date(from: components) else {
            return nil
        }

        if hourStart > date {
            return hourStart
        }

        return calendar.date(byAdding: .hour, value: 1, to: hourStart)
    }

    @objc private func handleTimer() {
        playChimeIfNeeded(at: Date())
        scheduleNextChime(after: Date())
    }

    private func playChimeIfNeeded(at date: Date) {
        guard let hourStart = calendar.dateInterval(of: .hour, for: date)?.start else {
            playBeep()
            return
        }

        guard lastPlayedHour != hourStart else {
            return
        }

        lastPlayedHour = hourStart
        playBeep()
    }

    private func playBeep() {
        guard let url = Bundle.main.url(forResource: "beep", withExtension: "mp3") else {
            NSLog("Menucal hourly chime skipped: beep.mp3 not found in bundle.")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            NSLog("Menucal hourly chime failed: \(error.localizedDescription)")
        }
    }
}
