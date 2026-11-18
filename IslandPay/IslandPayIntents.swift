import ActivityKit
import AppIntents
import Foundation

/// 快捷指令动作：启动灵动岛。
///
/// 供「快捷指令」自动化调用（例如「打开某 App 时」触发）。
/// 若已有活动在跑则更新它，不重复启动多个。
/// Intent 在后台运行，不打开 App。
struct StartIslandIntent: AppIntent {
    static var title: LocalizedStringResource = "启动灵动岛"
    static var description = IntentDescription("启动岛付的灵动岛实时活动，长按灵动岛可使用微信支付快捷入口。")

    func perform() async throws -> some IntentResult {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw IslandIntentError.activitiesNotEnabled
        }

        let state = IslandPayAttributes.ContentState(startedAt: Date())
        let content = ActivityContent(state: state, staleDate: nil)

        if let activity = Activity<IslandPayAttributes>.activities.first {
            // 已有活动在跑：更新状态，不重复启动。
            await activity.update(content)
        } else {
            _ = try Activity<IslandPayAttributes>.request(
                attributes: IslandPayAttributes(),
                content: content,
                pushType: nil
            )
        }
        return .result()
    }
}

/// 快捷指令动作：停止灵动岛。
struct StopIslandIntent: AppIntent {
    static var title: LocalizedStringResource = "停止灵动岛"
    static var description = IntentDescription("结束岛付的灵动岛实时活动。")

    func perform() async throws -> some IntentResult {
        for activity in Activity<IslandPayAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        return .result()
    }
}

/// 岛付快捷指令动作的报错。
enum IslandIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case activitiesNotEnabled

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .activitiesNotEnabled:
            return "实时活动未开启，请在「设置 → 岛付 → 实时活动」中打开开关。"
        }
    }
}

/// 把两个动作暴露给快捷指令与 Siri。
struct IslandPayShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: StartIslandIntent(), phrases: [
            "用${applicationName}启动灵动岛",
        ])
        AppShortcut(intent: StopIslandIntent(), phrases: [
            "用${applicationName}停止灵动岛",
        ])
    }
}
