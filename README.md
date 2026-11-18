# 岛付 IslandPay

一个带灵动岛实时活动（Live Activity）的启动器 App。

打开 App 点「启动灵动岛」，灵动岛上出现绿色小圆点＋「支付」；**长按灵动岛展开**，里面有两个按钮：

| 按钮 | 点了之后 |
|---|---|
| 微信支付 | 跳转微信付款码页面（`weixin://widget/pay`） |
| 扫一扫 | 跳转微信扫码页面（`weixin://scanqrcode`） |

## 工程结构

```
IslandPay.xcodeproj/          Xcode 工程（手写 project.pbxproj，两个 target）
IslandPay/                    App target（SwiftUI）
  IslandPayApp.swift          @main 入口
  ContentView.swift           主界面：启动/停止灵动岛，ActivityKit 启动代码在这里
  IslandPayAttributes.swift   共享的 ActivityAttributes（同时属于两个 target）
  Info.plist                  NSSupportsLiveActivities=YES、LSApplicationQueriesSchemes 含 weixin
  Assets.xcassets/            App 图标（微信绿底＋自绘二维码图案，无真实微信 logo）
IslandPayWidget/              Widget Extension target（WidgetKit）
  IslandPayWidgetBundle.swift @main WidgetBundle
  IslandPayWidget.swift       ActivityConfiguration + DynamicIsland 展开/紧凑/最小视图
  Info.plist                  NSExtensionPointIdentifier = com.apple.widgetkit-extension
.github/workflows/build.yml  GitHub Actions 无签名编译，打包 IPA
```

- 最低系统 iOS 17.0，Swift 5，无第三方依赖，Xcode 16+ 可编译。
- Bundle ID：`com.xin.islandpay`（占位，自签时会重签成自己的）。
- 不需要特殊 entitlements（本地启动的 Live Activity 不需要推送权限）。

## 关键实现

**启动实时活动**（`IslandPay/ContentView.swift` 的 `startActivity()`）：

```swift
guard ActivityAuthorizationInfo().areActivitiesEnabled else {
    showPermissionAlert = true  // 弹窗引导去「设置 → 岛付 → 实时活动」打开
    return
}
let activity = try Activity<IslandPayAttributes>.request(
    attributes: IslandPayAttributes(),
    content: ActivityContent(state: .init(startedAt: Date()), staleDate: nil),
    pushType: nil
)
```

**岛内按钮**（`IslandPayWidget/IslandPayWidget.swift`，iOS 17+ 可交互实时活动）：

```swift
Button(intent: OpenURLIntent(URL(string: "weixin://widget/pay")!)) {
    // 绿色圆角图标 +「微信支付」文字
}
```

用系统 `OpenURLIntent`：点按钮时系统收到 Intent 后打开对应 URL，扩展进程本身不直接开链接。

## 用 GitHub Actions 编译（没有 Mac 也能编）

1. 在 GitHub 新建一个仓库，把整个工程推上去（`git init` → `git add .` → `git commit` → `git push`）。
2. 推到 `main` 分支后，仓库的 **Actions** 页会自动跑 `Build IslandPay`（也可以点 **Run workflow** 手动跑）。
3. 跑完后在那次运行的页面底部 **Artifacts** 里下载 `IslandPay-unsigned-ipa`，解压得到 `IslandPay.ipa`（无签名版）。

## 用 SideStore 自签安装

1. 把 `IslandPay.ipa` 传到 iPhone（隔空投送 / 文件 App / 网盘都行）。
2. 打开 SideStore，点 ＋ 号选这个 IPA，选自己的 Apple ID 签名安装。
3. 首次打开 App 时，系统会问是否允许实时活动，点允许；如果之前拒绝过，去「设置 → 岛付 → 实时活动」打开。
4. 打开 App 点「启动灵动岛」，长按灵动岛就能看到两个按钮。

免费 Apple ID 签名 7 天过期，过期后用 SideStore 续签即可（App 数据和已启动的实时活动不受影响）。

## 8 小时过期说明

iOS 的实时活动最长存活约 8 小时，到期后系统会自动结束，灵动岛上的入口消失——这是苹果的限制，所有 App 都一样。消失后回到「岛付」App 再点一次「启动灵动岛」即可。

## 微信链接可能失效的说明

`weixin://widget/pay`（付款码）和 `weixin://scanqrcode`（扫一扫）是微信的非公开 URL Scheme，微信可能在某次版本更新中改掉或封掉。如果某天点按钮没反应、只打开微信首页或打不开，就是微信侧变了，需要找新的 Scheme，改 `IslandPayWidget/IslandPayWidget.swift` 顶部的两个链接常量，重新编译安装。

## 自定义

- 改按钮跳转目标：改 `IslandPayWidget/IslandPayWidget.swift` 顶部的 `weChatPayURL` / `weChatScanURL`。
- 加第三个按钮：在 `DynamicIslandExpandedRegion(.bottom)` 的 `HStack` 里再加一个 `Button(intent: OpenURLIntent(...))` 即可（注意展开视图宽度有限，三个按钮会比较挤）。
