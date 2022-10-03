//
//  ImagePicker.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 16.09.22.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> some UIViewController {
        var phPickerConfig = PHPickerConfiguration()
        phPickerConfig.filter = .images
        phPickerConfig.selectionLimit = 1
        phPickerConfig.preferredAssetRepresentationMode = .current

        let phPickerViewController = PHPickerViewController(configuration: phPickerConfig)
        phPickerViewController.delegate = context.coordinator

        return phPickerViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension ImagePicker {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let phPickerResult = results.first else {
                return
            }

            let itemProvider = phPickerResult.itemProvider

            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { itemProviderReading, _ in
                    DispatchQueue.main.async {
                        self.parent.image = itemProviderReading as? UIImage
                    }
                }
            }
        }
    }
}
