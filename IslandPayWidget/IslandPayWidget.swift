import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

/// 微信付款码 / 扫一扫的跳转链接（微信 URL Scheme）。
/// 注意：微信可能在版本更新中调整 Scheme，如某天点按钮打不开，
/// 即为微信侧变更，需换新的 Scheme（见 README）。
private let weChatPayURL = URL(string: "weixin://widget/pay")!
private let weChatScanURL = URL(string: "weixin://scanqrcode")!

struct IslandPayWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IslandPayAttributes.self) { context in
            // 锁屏横幅视图
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green)
                        .frame(width: 36, height: 36)
                    Image(systemName: "qrcode")
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("岛付 · 微信支付")
                        .font(.headline)
                    Text("启动于 \(context.state.startedAt, style: .time) · 长按灵动岛使用快捷入口")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        } dynamicIsland: { context in
            DynamicIsland {
                // 展开视图上半部分：标题行
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                        Text("岛付")
                            .font(.headline)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: "qrcode")
                        .foregroundStyle(.green)
                }
                // 展开视图下半部分：两个跳转按钮。
                // 必须用 Button(intent: OpenURLIntent(...))：实测 Link(destination:)
                // 在实时活动里对微信自定义 Scheme 不生效，点按会落到整个岛上、
                // 跳回 App。OpenURLIntent 在应用扩展里要求 iOS 18+，
                // 本工程最低部署目标已提到 iOS 18.0。
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        // ① 微信付款码
                        Button(intent: OpenURLIntent(url: weChatPayURL)) {
                            HStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green)
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "qrcode")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                Text("微信支付")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)

                        // ② 微信扫一扫
                        Button(intent: OpenURLIntent(url: weChatScanURL)) {
                            HStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green)
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "viewfinder")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                Text("扫一扫")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("支付")
                        .font(.caption2.weight(.semibold))
                }
            } compactTrailing: {
                Image(systemName: "qrcode")
                    .foregroundStyle(.green)
            } minimal: {
                Circle()
                    .fill(Color.green)
            }
            .keylineTint(.green)
        }
    }
}
