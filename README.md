# MacCalendar

MacCalendar 是一款原生 macOS 菜单栏日历应用，界面参考 Itsycal 的轻量弹窗体验，并加入农历、节气、中国节假日、系统日程管理和整点报时等功能。

![SwiftUI](https://img.shields.io/badge/SwiftUI-EC662F?style=flat&logo=swift&logoColor=white)
[![macOS](https://img.shields.io/badge/macOS-14.6+-green.svg)](https://github.com/ervinsae/MacCalendar/releases/latest)
![GitHub Release](https://img.shields.io/github/v/release/ervinsae/MacCalendar)

## 功能亮点

- 菜单栏常驻，点击即可打开紧凑的月历弹窗。
- 支持公历、农历、24 节气、传统节日和 2015-2026 年中国法定节假日/调休数据。
- 支持周一或周日作为每周第一天，可选显示周数。
- 周六、周日整列背景高亮，日期格展示系统日程颜色点。
- 日程列表按当前选中日期展示“今天、明天、后天、星期几”，右侧显示具体日期。
- 已过去日程自动置灰，未开始日程保持正常显示。
- 日程详情独立弹窗显示标题、时间、地点、组织者、与会人员、备注和链接。
- 日程详情中的链接可点击打开；与会人员按接受、拒绝、待定状态显示不同颜色圆点。
- 支持新增、编辑、删除系统日历事件。
- 支持按日历源筛选日程，并可跳转系统日历权限设置。
- 工具栏可快速新增事件、打开系统日历、打开应用设置。
- 菜单栏显示内容可自定义为图标、日期、时间或自定义格式，支持双行显示。
- 支持浅色、深色、跟随系统外观。
- 支持开机自启动。
- 支持检查 GitHub Release 更新并下载 DMG。
- 支持整点报时：整点时播放内置 `beep.mp3`。

## 截图

<p>
  <img width="226" alt="日历主界面" src="screenshots/calendar_main.png" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img width="512" alt="事件详情" src="screenshots/event_detail.png" />
</p>

## 安装

1. 前往 [GitHub Releases](https://github.com/ervinsae/MacCalendar/releases/latest) 下载最新版本的 `MacCalendar-*.dmg`。
2. 打开 DMG，将 `MacCalendar.app` 拖入 `Applications`。
3. 首次启动后，根据系统提示授予日历访问权限。

由于当前构建未进行 Apple Developer ID 签名，如果 macOS 提示无法验证开发者，可在“系统设置 -> 隐私与安全性”中选择仍要打开，或执行：

```bash
xattr -cr /Applications/MacCalendar.app
```

## 使用

- 点击菜单栏图标打开日历弹窗。
- 点击日期切换日程列表。
- 点击日程打开详情，再次点击同一日程可关闭详情。
- 点击工具栏 `+` 新增日程。
- 点击工具栏日历图标打开系统日历。
- 点击工具栏设置图标打开 MacCalendar 设置。
- 在设置中可调整菜单栏显示、日历筛选、周数、外观、开机自启和更新检查。

## 本地开发

```bash
git clone https://github.com/ervinsae/MacCalendar.git
cd MacCalendar
open MacCalendar.xcodeproj
```

命令行构建：

```bash
xcodebuild -project MacCalendar.xcodeproj \
  -scheme MacCalendar \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 技术栈

| 技术 | 说明 |
| --- | --- |
| SwiftUI | 主界面和设置界面 |
| AppKit | 菜单栏 `NSStatusItem`、`NSPopover`、窗口管理 |
| EventKit | 读取、新增、编辑、删除系统日历事件 |
| Combine | 设置变更和菜单栏内容刷新 |
| AVFoundation | 整点报时音频播放 |

## 项目结构

```text
MacCalendar/
├── AppDelegate.swift              # 菜单栏、主弹窗、日程详情弹窗管理
├── MacCalendarApp.swift           # App 入口
├── Core/
│   ├── CalendarManager.swift      # 日历数据、事件读写、权限和缓存
│   ├── HourlyChimeService.swift   # 整点报时
│   ├── LaunchAtLoginManager.swift # 开机自启动
│   ├── SettingsManager.swift      # 偏好设置
│   └── UpdateManager.swift        # GitHub Release 更新检查
├── Models/                        # 日历、日程、设置模型
├── Utils/                         # 农历、节气、节假日、日期工具
├── Views/                         # 月历、日程列表、详情、编辑、设置
├── Data/                          # 中国法定节假日数据
└── beep.mp3                       # 整点报时音频
```

## 隐私

MacCalendar 通过系统 EventKit 访问本机日历数据。日历事件的读取和修改均在本机完成，不会上传日历内容。只有在用户手动检查更新或下载更新时，应用会访问 GitHub Release。

## 发布

推送 `v*` 标签会触发 GitHub Actions 自动构建 Release 版 App、打包 DMG，并将 DMG 上传到对应的 GitHub Release。

## 致谢

- [Itsycal](https://www.mowglii.com/itsycal/)：MacCalendar 的弹窗交互和视觉方向参考了这款优秀的 macOS 菜单栏日历。
- [NateScarlet/holiday-cn](https://github.com/NateScarlet/holiday-cn)：中国法定节假日数据来源。

## 开源协议

本项目基于 MIT 协议开源，详见 [LICENSE](LICENSE)。
