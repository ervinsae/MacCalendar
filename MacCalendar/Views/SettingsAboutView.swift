//
//  SettingsAbout.swift
//  Menucal
//
//  Created by ruihelin on 2025/10/6.
//

import AppKit
import SwiftUI

struct SettingsAboutView: View {
    private let features = [
        AboutFeature(symbol: "calendar", title: "日历视图"),
        AboutFeature(symbol: "list.bullet.clipboard", title: "日程管理"),
        AboutFeature(symbol: "moon.stars", title: "农历支持"),
        AboutFeature(symbol: "sun.max", title: "24 节气"),
        AboutFeature(symbol: "paintbrush", title: "个性化配置"),
        AboutFeature(symbol: "flag", title: "中国假期"),
        AboutFeature(symbol: "speaker.wave.2", title: "整点报时"),
        AboutFeature(symbol: "heart", title: "开源免费")
    ]

    var body: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    Image(nsImage: NSApplication.shared.applicationIconImage)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: 52, height: 52)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("Menucal")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))

                            Text("版本 \(Bundle.main.appVersion ?? "1.0.0")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("完全免费且开源的 macOS 小而美菜单栏日历")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }

            Section("核心功能") {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 2),
                    alignment: .leading,
                    spacing: 4
                ) {
                    ForEach(features) { feature in
                        AboutFeatureRow(feature: feature)
                    }
                }
            }

            Section {
                Link(destination: URL(string: "https://github.com/ervinsae/Menucal")!) {
                    HStack(spacing: 10) {
                        Image("github-logo")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)

                        Text("GitHub 仓库")

                        Spacer()

                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } header: {
                Text("项目信息")
            } footer: {
                Text("© 2026 Menucal")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AboutFeature: Identifiable {
    let symbol: String
    let title: String

    var id: String { title }
}

private struct AboutFeatureRow: View {
    let feature: AboutFeature

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: feature.symbol)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.tint)
                .frame(width: 18)

            Text(feature.title)
                .font(.callout)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SettingsAboutView()
}
