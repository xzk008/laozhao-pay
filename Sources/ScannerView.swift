import SwiftUI
import AVFoundation
import AudioToolbox

/// 实时相机扫码（原生，比网页版强，不需要 HTTPS）
struct ScannerScreen: View {
    let onFound: (String) -> Void

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            CameraScannerView { code in
                onFound(code)
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.black.opacity(0.45)))
                    }
                    Spacer()
                    Text("把二维码放进框里")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.black.opacity(0.45)))
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.9), lineWidth: 3)
                    .frame(width: 250, height: 250)

                Spacer()
            }
        }
    }
}

/// AVCaptureSession 的 SwiftUI 包装
struct CameraScannerView: UIViewControllerRepresentable {
    let onFound: (String) -> Void

    func makeUIViewController(context: Context) -> CameraScannerVC {
        let vc = CameraScannerVC()
        vc.onFound = onFound
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraScannerVC, context: Context) {}
}

final class CameraScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var onFound: ((String) -> Void)?

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var finished = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            showHint("无法访问相机，请到「设置 → 隐私 → 相机」里允许")
            return
        }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            showHint("相机初始化失败")
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [.qr]

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        previewLayer = layer

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }

    private func stop() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }

    private func showHint(_ text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !finished else { return }
        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = obj.stringValue,
              !value.isEmpty else { return }

        finished = true
        stop()
        AudioServicesPlaySystemSound(1057)
        onFound?(value)
    }
}
