import UIKit

/// 唤起支付宝
///
/// 用的是支付宝公开的端外唤起容器（和安卓版 SDK 内部用的是同一套协议）：
///   alipays://platformapi/startapp?appId=20000067&url=<订单串>
enum PayLauncher {

    static let schemePrefix = "alipays://platformapi/startapp?appId=20000067&url="

    /// 把订单串编码成完整的唤起链接（可在“复制唤起链接”里查看）
    static func link(for order: String) -> String {
        let trimmed = order.trimmingCharacters(in: .whitespacesAndNewlines)
        // alphanumerics 是 encodeURIComponent 的超集，多编码几个符号不影响解码结果
        let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        return schemePrefix + encoded
    }

    /// 打开支付宝。completion 的 Bool 表示系统是否接受了这次跳转
    static func open(order: String, completion: @escaping (Bool) -> Void) {
        guard !order.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = URL(string: link(for: order)) else {
            completion(false)
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:]) { ok in
                completion(ok)
            }
        }
    }
}
