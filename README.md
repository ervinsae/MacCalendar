# MacCalendar

完全免费、开源的离线小而美 macOS 菜单栏日历 App

![SwiftUI](https://img.shields.io/badge/SwiftUI-EC662F?style=flat&logo=swift&logoColor=white)
[![macOS](https://img.shields.io/badge/macOS-14.0+-green.svg)](https://github.com/bylinxx/MacCalendar/releases/latest)
![GitHub Release](https://img.shields.io/github/v/release/bylinxx/MacCalendar)

## 关于本项目

MacCalendar 是一款开源的 macOS 菜单栏日历应用，使用 **SwiftUI + AppKit** 原生开发。

本项目的 UI 设计灵感来源于 [Itsycal](https://www.mowglii.com/itsycal/)——一款优秀的 macOS 菜单栏日历软件。MacCalendar 在此基础上使用 SwiftUI 进行了全新实现，并针对中国用户的需求增加了**农历、24节气、中国法定节假日调休**等本地化功能，是一个面向中文用户的 Itsycal 替代方案。

> 感谢 Itsycal 为 macOS 日历类应用树立的标杆，MacCalendar 向其致敬。

## 主要功能

> [!TIP]   
> - 界面简洁精致，轻量化占用资源极小，完全离线不需要联网  
> - 运行后静默显示在菜单栏，右键或者按快捷键[Command + ，]打开设置窗口
> - 中国农历、24节气、大部分节日（公历或农历）  
> - 中国法定放假安排（自2015年以来）  
> - 个性化图标、日历类型、周数等显示  
> - 读取系统日历数据，可按类型筛选显示，支持修改和删除
> - 自定义菜单栏显示内容，支持图标/日期/时间/自定义格式
> - 输入年/月快捷跳转

## 技术栈

| 技术 | 说明 |
|:---|:---|
| SwiftUI | 主要 UI 框架 |
| AppKit | 菜单栏 `NSStatusItem`、`NSPopover`、窗口管理 |
| EventKit | 读取 / 修改系统日历事件 |
| Combine | 响应式数据流与状态管理 |

### 项目结构

```
MacCalendar/
├── MacCalendarApp.swift       # App 入口
├── AppDelegate.swift          # 菜单栏 StatusItem、Popover 管理
├── Core/
│   ├── CalendarManager.swift  # 日历数据管理与缓存
│   ├── SettingsManager.swift  # 偏好设置
│   ├── UpdateManager.swift    # 应用更新检查
│   └── LaunchAtLoginManager.swift
├── Models/
│   ├── CalendarDay.swift      # 日历天数据模型
│   ├── CalendarEvent.swift    # 事件数据模型
│   ├── CalendarIcon.swift     # 菜单栏图标显示逻辑
│   └── ...
├── Views/
│   ├── ContentView.swift      # 主视图容器 & 调色板
│   ├── CalendarView.swift     # 月历视图
│   ├── EventListView.swift    # 事件列表 & 工具栏
│   ├── EventDetailView.swift  # 事件详情
│   ├── EventEditView.swift    # 事件编辑
│   └── Settings*.swift        # 设置页面
├── Utils/
│   ├── LunarDateHelper.swift  # 农历计算
│   ├── SolarTermHelper.swift  # 24节气计算
│   ├── HolidayHelper.swift    # 节日判断
│   ├── OffdayHelper.swift     # 调休判断
│   └── DateHelper.swift       # 日期工具
└── Data/
    └── 20xx.json              # 2015—2026 法定节假日数据
```


## 安装

> [!NOTE]
> - **手动安装**
>   1. 从 [GitHub Releases](https://github.com/bylinxx/MacCalendar/releases/latest) 下载最新版本 dmg 格式的镜像
>   2. 双击打开下载的 dmg 镜像
>   3. 拖动MacCalendar图标到Applications图标完成安装
>   4. 如何更新？偏好设置->检查更新
> - **homebrew安装**
>   1. 在命令行执行 brew tap bylinxx/tap 引入tap
>   2. 在命令行执行 brew install maccalendar 完成安装
>   3. 由于没有购买开发者签名，首次打开会提示"无法验证开发者"或"应用已损坏"，必须在"系统设置 -> 隐私与安全性 -> 安全性"中点击"仍要打开"，或者在终端执行 xattr -cr /Applications/MacCalendar.app 来移除安全隔离标记
>   4. 如何更新？偏好设置->检查更新

## 界面截图

<p>
  <img width="226" alt="日历主界面" src="screenshots/calendar_main.png" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img width="512" alt="事件详情" src="screenshots/event_detail.png" />
</p>

## 致谢

- **[Itsycal](https://www.mowglii.com/itsycal/)** — 优秀的 macOS 菜单栏日历，MacCalendar 的 UI 设计灵感来源
- **[NateScarlet/holiday-cn](https://github.com/NateScarlet/holiday-cn)** — 中国法定节假日数据来源

## 支持开发

[<img width="200" src="https://pic1.afdiancdn.com/static/img/welcome/button-sponsorme.png" alt="afdian">](https://afdian.com/a/macmc)

## 参与贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的改动 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到远端 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 开源协议

本项目基于 MIT 协议开源，详见 [LICENSE](LICENSE) 文件。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=bylinxx/MacCalendar&type=Timeline)](https://www.star-history.com/#bylinxx/MacCalendar&Timeline)
