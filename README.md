# 老赵专用 · iOS 版

和安卓版界面一致的 iPhone 版：**扫码 / 粘单 → 唤起支付宝付款**。

- 用 **SwiftUI** 写，界面照搬安卓版的 B3 方案（紫蓝渐变头部 + 弧形底 + 白卡片 + 胶囊分段）
- 扫码用**原生 AVFoundation**（实时扫，不需要 HTTPS），也能从相册选图用 `CIDetector` 离线识别
- 唤起支付宝用的是同一个协议：`alipays://platformapi/startapp?appId=20000067&url=<订单串>`
- **不依赖任何第三方库、不需要 CocoaPods**，编译干净利落

---

## ⚠️ 先看这一条

**IPA 必须由 macOS 上的 Xcode 编译**（iOS SDK / clang 的 Darwin 后端 / codesign 都只在 macOS 上）。任何 Windows 机器都做不了这件事，这是苹果的硬限制。

所以下面给两条路，**按你手上有没有 Mac 选一条**：

| | 你需要的 | 大概耗时 |
|---|---|---|
| **路线 A** | 一台 Mac（或 MacinCloud 之类的云 Mac） | 10 分钟 |
| **路线 B** | 一个 GitHub 账号（免费） | 20 分钟 |

两条路最后都要「签名」才能装进没越狱的 iPhone，签名方式见下面第 3 节。

---

## 路线 A：有 Mac

```bash
# 1. 装 XcodeGen（生成 .xcodeproj 用）
brew install xcodegen

# 2. 在本目录生成 Xcode 工程
xcodegen generate

# 3. 打开
open LaozhaoPay.xcodeproj
```

然后在 Xcode 里：
1. 选中 `LaozhaoPay` target → **Signing & Capabilities**
2. 勾上 **Automatically manage signing**，Team 选你的 Apple ID
3. 插上 iPhone，选设备，点 ▶️ Run

想要 .ipa 文件的话：**Product → Archive → Distribute App → Development**。

---

## 路线 B：没有 Mac，用 GitHub 免费云编译

GitHub Actions 提供**免费的 macOS 机器**（公开仓库不限时长），我已经把流水线写好了：`.github/workflows/build-ipa.yml`。

### 步骤

1. **注册/登录 GitHub**：https://github.com
2. **新建一个仓库**（Public 或 Private 都行，名字随意，比如 `laozhao-pay`）
3. **把本文件夹的全部内容传上去**。不会用 git 的话，在仓库页面点 **Add file → Upload files**，把 `Sources`、`.github`、`project.yml` 拖进去提交即可
   > `.github` 是隐藏文件夹，Windows 资源管理器里要先「查看 → 显示隐藏项目」才看得到
4. 进仓库的 **Actions** 标签页 → 左边选 **Build unsigned IPA** → 右边点 **Run workflow**
5. 等 3～5 分钟，跑完后点进这次运行，页面底部 **Artifacts** 里下载 `LaozhaoPay-unsigned-ipa.zip`
6. 解压得到 **`LaozhaoPay-unsigned.ipa`** ← 这就是你要的安装包（未签名）

> 以后想改界面，改完重新上传、重新点一次 Run workflow 就行。

---

## 3. 把 IPA 装到 iPhone 上

未签名的 IPA 不能直接装，需要用你的 Apple ID 签一次。**这一步在 Windows 上就能做。**

### 工具：Sideloadly

1. 下载 https://sideloadly.io
2. **先装 Apple 官网的 iTunes**（不是 Microsoft Store 那个版本！）—— Sideloadly 需要它提供的苹果驱动
   - 或者只装 "Apple Mobile Device Support"
3. iPhone 用数据线连电脑，手机上点「信任此电脑」
4. 打开 Sideloadly：
   - **IPA**：选刚下载的 `LaozhaoPay-unsigned.ipa`
   - **Apple ID**：填你的 Apple ID（免费账号就行）
   - 点 **Start**，会让你输 Apple ID 密码，可能还要 App 专用密码
5. 等它跑完，手机上会出现「老赵专用」

### 手机上还要做两步（不然打不开）

1. **信任证书**：设置 → 通用 → VPN 与设备管理 → 找到你的 Apple ID → **信任**
2. **开发者模式**（iOS 16 及以上必须）：设置 → 隐私与安全性 → **开发者模式** → 打开 → 重启手机

### 免费 Apple ID 的限制

| | 免费 Apple ID | 开发者账号（$99/年） |
|---|---|---|
| 有效期 | **7 天**，到期要重新签一次 | 1 年 |
| 同时装的 App | 最多 3 个 | 100 个 |
| 说明 | 重签用 Sideloadly 再点一次 Start 即可，数据不丢 | 省心 |

> **如果 iPhone 的系统版本在 TrollStore 支持范围内（iOS 14.0–16.6.1 / 17.0）**，可以用 [TrollStore](https://github.com/opa334/TrollStore) 直接装未签名 IPA，**永久有效、不用 Apple ID、不用电脑**。先查一下你的系统版本，如果在范围内这是最省事的办法。

---

## 4. 工程结构

```
ios/
├─ project.yml                       XcodeGen 工程定义
├─ Sources/
│  ├─ LaozhaoApp.swift               入口
│  ├─ ContentView.swift              主界面（B3 布局）
│  ├─ Theme.swift                    配色 + 弧形 Shape
│  ├─ ScannerView.swift              原生实时扫码（AVFoundation）
│  ├─ PhotoPicker.swift              相册选图识别（CIDetector）
│  ├─ PayLauncher.swift              拼唤起链接 + 打开支付宝
│  ├─ Info.plist                     相机权限 / URL Scheme / 查询白名单
│  └─ Assets.xcassets/               图标（已生成全套尺寸）
└─ .github/workflows/build-ipa.yml   云编译流水线
```

---

## 5. 已知限制（和安卓版的差别）

| | 说明 |
|---|---|
| **沙箱环境** | ❌ 支付宝官方不提供 iOS 沙箱钱包，界面上保留了这个开关但实际只能走正式环境 |
| **支付结果回调** | ❌ 这个版本没接支付宝 iOS SDK，只负责「唤起」，拿不到 `resultStatus`。要走完整流程得加 `AlipaySDK-iOS`（CocoaPods），工程结构已留好位置 |
| **编译验证** | ⚠️ 这份代码是在 Windows 上写的，**我这边没有 Xcode，没法编译验证**。第一次 `xcodebuild` 可能要修一两个小报错 —— 把报错发我，我给你改 |

---

## 6. 出问题怎么排查

| 现象 | 原因 / 处理 |
|---|---|
| `xcodegen: command not found` | 没装 XcodeGen：`brew install xcodegen` |
| 编译报 `Signing for "LaozhaoPay" requires a development team` | 云编译不需要；本地 Xcode 要选 Team。或确认 xcodebuild 带了 `CODE_SIGNING_ALLOWED=NO` |
| 云编译失败在 Package/Resolve 阶段 | 本工程没有任何依赖，正常不会；把日志发我 |
| 手机装上了但点开闪退 | 多半是没开**开发者模式**，或证书没信任 |
| 点付款没反应 | 确认装了支付宝；点「复制唤起链接」粘到 Safari 地址栏能唤起就说明链接没问题 |
| 扫码黑屏 | 相机权限被拒了：设置 → 隐私 → 相机 → 打开 |
