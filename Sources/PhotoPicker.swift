import SwiftUI
import PhotosUI
import CoreImage
import UIKit

/// 从相册选一张二维码图片并离线识别（用系统 CIDetector，不依赖任何第三方库）
struct PhotoPicker: UIViewControllerRepresentable {
    let onFound: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onFound: onFound)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {

        private let onFound: (String) -> Void

        init(onFound: @escaping (String) -> Void) {
            self.onFound = onFound
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                guard let self = self,
                      let image = object as? UIImage,
                      let cgImage = image.cgImage else { return }

                let ciImage = CIImage(cgImage: cgImage)
                let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                          context: nil,
                                          options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
                let features = detector?.features(in: ciImage) ?? []

                for feature in features {
                    if let qr = feature as? CIQRCodeFeature,
                       let message = qr.messageString,
                       !message.isEmpty {
                        DispatchQueue.main.async { self.onFound(message) }
                        return
                    }
                }
            }
        }
    }
}
