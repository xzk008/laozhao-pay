import SwiftUI

/// 配色与圆角，和安卓版 B3 方案一一对应
enum Palette {
    static let brand      = Color(red: 0x5B / 255.0, green: 0x5B / 255.0, blue: 0xFF / 255.0)
    static let brandDark  = Color(red: 0x2E / 255.0, green: 0x1A / 255.0, blue: 0x6B / 255.0)
    static let brandDeep  = Color(red: 0x4A / 255.0, green: 0x4A / 255.0, blue: 0xE0 / 255.0)
    static let pageBG     = Color(red: 0xF2 / 255.0, green: 0xF1 / 255.0, blue: 0xFA / 255.0)
    static let trackBG    = Color(red: 0xF1 / 255.0, green: 0xF0 / 255.0, blue: 0xFB / 255.0)
    static let editBorder = Color(red: 0xE9 / 255.0, green: 0xE7 / 255.0, blue: 0xF6 / 255.0)
    static let textMain   = Color(red: 0x1A / 255.0, green: 0x1E / 255.0, blue: 0x2E / 255.0)
    static let textSub    = Color(red: 0x8A / 255.0, green: 0x90 / 255.0, blue: 0xA3 / 255.0)
    static let disabled   = Color(red: 0xC9 / 255.0, green: 0xCA / 255.0, blue: 0xE8 / 255.0)
}

/// 头部弧形底：上边平、下边向下鼓起的弧
struct ArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: rect.width, y: 0))
        p.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.30))
        p.addQuadCurve(to: CGPoint(x: 0, y: rect.height * 0.30),
                       control: CGPoint(x: rect.width * 0.5, y: rect.height * 1.70))
        p.closeSubpath()
        return p
    }
}
