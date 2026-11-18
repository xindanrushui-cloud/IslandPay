import ActivityKit
import Foundation

/// 岛付 Live Activity 的共享属性定义。
///
/// 本文件同时加入 App target 与 Widget Extension target，
/// 两边共用同一份定义（在 project.pbxproj 中是同一个 fileRef、
/// 两条 PBXBuildFile 记录）。
struct IslandPayAttributes: ActivityAttributes {

    /// 实时活动中会变化的状态。
    public struct ContentState: Codable, Hashable {
        /// 启动时间（锁屏横幅视图可显示）。
        var startedAt: Date
    }

    // 没有固定属性：两个按钮的跳转链接是固定的，
    // 不需要随每次 Activity 启动而变化。
}
