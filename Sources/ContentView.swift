import SwiftUI
import UIKit

struct ContentView: View {

    @State private var order = ""
    @State private var isFormal = true
    @State private var showScanner = false
    @State private var showPicker = false
    @State private var toastText: String?
    @State private var showToast = false

    private let storeKey = "lz_order"

    // MARK: - 派生状态

    private var trimmed: String { order.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var ready: Bool { !trimmed.isEmpty }
    private var looksValid: Bool { trimmed.contains("app_id=") || trimmed.contains("sign=") }

    // MARK: - Body

    var body: some View {
        ZStack {
            Palette.pageBG.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    card.padding(.top, -25)
                    tipSection
                    footer
                }
            }

            toastLayer
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showScanner) {
            ScannerScreen { code in
                showScanner = false
                handleScanned(code)
            }
        }
        .sheet(isPresented: $showPicker) {
            PhotoPicker { code in
                showPicker = false
                handleScanned(code)
            }
        }
        .onAppear {
            if let saved = UserDefaults.standard.string(forKey: storeKey) {
                order = saved
            }
        }
        .onChange(of: order) { value in
            UserDefaults.standard.set(value, forKey: storeKey)
        }
    }

    // MARK: - 头部

    private var header: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                LinearGradient(
                    gradient: Gradient(colors: [Palette.brandDark, Palette.brand]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 143)

                VStack(spacing: 18) {
                    Text("上海滩的那一站，老赵扬名又立万")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)

                    Text(isFormal ? "● 正式环境" : "● 沙箱环境")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.2)))
                }
                .padding(.top, 34)
            }

            ArcShape()
                .fill(Palette.brand)
                .frame(height: 65)
        }
    }

    // MARK: - 卡片

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {

            // 环境切换
            HStack(spacing: 0) {
                segmentItem(title: "正式环境", on: isFormal) { isFormal = true }
                segmentItem(title: "沙箱环境", on: !isFormal) { isFormal = false }
            }
            .padding(3)
            .background(Capsule().fill(Palette.trackBG))
            .frame(height: 40)

            if !isFormal {
                Text("iOS 没有沙箱钱包，实际发起时仍会走正式环境")
                    .font(.system(size: 11))
                    .foregroundColor(Palette.textSub)
                    .padding(.top, 8)
            }

            // 签名串
            HStack {
                Text("签名串")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Palette.brand)
                Spacer()
                Text("\(trimmed.count) 字符")
                    .font(.system(size: 11))
                    .foregroundColor(Palette.textSub)
            }
            .padding(.top, 15)
            .padding(.bottom, 6)

            TextEditor(text: $order)
                .font(.system(size: 12))
                .foregroundColor(Palette.textMain)
                .frame(height: 84)
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Palette.editBorder, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if order.isEmpty {
                        Text("扫码自动填入，或手动粘贴服务端签名好的字符串")
                            .font(.system(size: 12))
                            .foregroundColor(Palette.textSub)
                            .padding(.top, 14)
                            .padding(.leading, 12)
                            .allowsHitTesting(false)
                    }
                }

            if ready && !looksValid {
                Text("这段内容看起来不像支付宝订单串，订单串里通常含有 app_id= 和 sign=")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0xB2 / 255.0, green: 0x6A / 255.0, blue: 0.0))
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 1.0, green: 0xF4 / 255.0, blue: 0xE5 / 255.0)))
                    .padding(.top, 10)
            }

            // 扫码 / 相册
            HStack(spacing: 10) {
                Button(action: { showScanner = true }) {
                    HStack(spacing: 7) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 16, weight: .semibold))
                        Text("扫码识别")
                            .font(.system(size: 16))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundColor(Palette.brandDeep)
                    .background(Capsule().stroke(Palette.disabled, lineWidth: 1.5))
                }

                Button(action: { showPicker = true }) {
                    HStack(spacing: 7) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 15, weight: .semibold))
                        Text("相册选图")
                            .font(.system(size: 16))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundColor(Palette.brandDeep)
                    .background(Capsule().stroke(Palette.disabled, lineWidth: 1.5))
                }
            }
            .padding(.top, 15)

            // 付款
            Button(action: pay) {
                HStack(spacing: 7) {
                    Image(systemName: "creditcard")
                        .font(.system(size: 16, weight: .semibold))
                    Text("打开支付宝付款")
                        .font(.system(size: 17, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundColor(.white)
                .background(Capsule().fill(ready ? Palette.brand : Palette.disabled))
            }
            .disabled(!ready)
            .padding(.top, 11)

            Button(action: copyLink) {
                Text("复制唤起链接（排查用）")
                    .font(.system(size: 13))
                    .foregroundColor(Palette.textSub)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color(red: 50 / 255.0, green: 60 / 255.0, blue: 100 / 255.0).opacity(0.12),
                        radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
    }

    private func segmentItem(title: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: on ? .bold : .regular))
                .foregroundColor(on ? .white : Palette.textSub)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(
                    Capsule().fill(on ? Palette.brand : Color.clear)
                )
        }
    }

    // MARK: - 说明 / 页脚

    private var tipSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("使用说明")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Palette.textMain)
            Text("1. 点「扫码识别」对着二维码拍，或用「相册选图」选一张二维码截图")
            Text("2. 识别成功后自动填进输入框，再点「打开支付宝付款」")
            Text("3. 付完切回本 App，支付结果本工具拿不到（没接支付宝 SDK）")

            Text("注意")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Palette.textMain)
                .padding(.top, 8)
            Text("· iPhone 上只能用正式环境：支付宝官方不提供 iOS 沙箱钱包")
            Text("· 弹不出支付宝时，点「复制唤起链接」粘到 Safari 地址栏验证一下")
        }
        .font(.system(size: 12))
        .foregroundColor(Palette.textSub)
        .lineSpacing(4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 22)
    }

    private var footer: some View {
        Text("超萌康🐷")
            .font(.system(size: 12))
            .foregroundColor(Palette.textSub)
            .frame(maxWidth: .infinity)
            .padding(.top, 26)
            .padding(.bottom, 24)
    }

    private var toastLayer: some View {
        Group {
            if showToast, let text = toastText {
                VStack {
                    Spacer()
                    Text(text)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Palette.textMain.opacity(0.92))
                        )
                        .padding(.horizontal, 40)
                        .padding(.bottom, 130)
                }
                .allowsHitTesting(false)
            }
        }
    }

    // MARK: - 行为

    private func handleScanned(_ code: String) {
        let value = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else {
            say("识别结果是空的，换个二维码试试")
            return
        }
        order = value
        say("识别成功！正在唤起支付宝…")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            pay()
        }
    }

    private func pay() {
        guard ready else {
            say("请先扫码或粘贴签名串")
            return
        }
        PayLauncher.open(order: order) { ok in
            if !ok {
                say("没唤起支付宝，请确认手机已安装支付宝")
            }
        }
    }

    private func copyLink() {
        guard ready else {
            say("请先扫码或粘贴签名串")
            return
        }
        UIPasteboard.general.string = PayLauncher.link(for: order)
        say("唤起链接已复制")
    }

    private func say(_ text: String, seconds: Double = 2.4) {
        toastText = text
        withAnimation(.easeInOut(duration: 0.18)) { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            withAnimation(.easeInOut(duration: 0.18)) { showToast = false }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
