import ActivityKit
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var currentActivity: Activity<IslandPayAttributes>?
    @State private var showPermissionAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private var isRunning: Bool { currentActivity != nil }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // 绿色圆角图标（自绘方块＋系统符号，不用真实微信 logo，避免商标图片）
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.green)
                    .frame(width: 96, height: 96)
                Image(systemName: "qrcode")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text("岛付")
                    .font(.largeTitle.bold())
                Text("灵动岛微信支付快捷入口")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                Label("长按灵动岛展开后，点「微信支付」直达付款码", systemImage: "hand.tap")
                Label("点「扫一扫」直达微信扫码", systemImage: "viewfinder")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            Button {
                Task {
                    if isRunning {
                        await stopActivity()
                    } else {
                        startActivity()
                    }
                }
            } label: {
                Text(isRunning ? "停止灵动岛" : "启动灵动岛")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isRunning ? Color.red : Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)

            Text(isRunning ? "实时活动运行中 · 长按灵动岛试试" : "实时活动未启动")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("提示：iOS 的实时活动最长存活约 8 小时，到期后系统会自动结束，需回到 App 重新启动。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            restoreActivity()
        }
        .alert("实时活动未开启", isPresented: $showPermissionAlert) {
            Button("去设置") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("请在「设置 → 岛付 → 实时活动」中打开开关，再回到 App 启动灵动岛。")
        }
        .alert("启动失败", isPresented: $showErrorAlert) {
            Button("好", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Live Activity

    /// 启动灵动岛实时活动。
    /// 首次启动时系统会弹出实时活动权限询问；用户若此前已拒绝，
    /// areActivitiesEnabled 为 false，走弹窗引导去设置里打开。
    private func startActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            showPermissionAlert = true
            return
        }

        let attributes = IslandPayAttributes()
        let initialState = IslandPayAttributes.ContentState(startedAt: Date())
        let content = ActivityContent(state: initialState, staleDate: nil)

        do {
            let activity = try Activity<IslandPayAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentActivity = activity
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    /// 结束实时活动，灵动岛立即收起。
    private func stopActivity() async {
        await currentActivity?.end(nil, dismissalPolicy: .immediate)
        currentActivity = nil
    }

    /// App 重开后恢复已在运行的 Activity，避免重复启动。
    private func restoreActivity() {
        currentActivity = Activity<IslandPayAttributes>.activities.first
    }
}
