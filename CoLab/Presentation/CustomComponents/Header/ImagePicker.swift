//
//  ChangeSettingsAvatarPicker.swift
//  CoLab
//
//  Created by User on 17.03.2026.
//

import UIKit
import PhotosUI

// Открывающееся окно с выбором фотографий из галереи
final class ImagePicker {
    
    private weak var presentingViewController: UIViewController?
    private let onImagePicked: (UIImage) -> Void
    
    init(
        presentingViewController: UIViewController,
        onImagePicked: @escaping (UIImage) -> Void
    ) {
        self.presentingViewController = presentingViewController
        self.onImagePicked = onImagePicked
    }
    
    func present() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        picker.modalPresentationStyle = .pageSheet
        
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        presentingViewController?.present(picker, animated: true)
    }
}

extension ImagePicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        guard provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let self else { return }
            guard let image = image as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.onImagePicked(image)
            }
        }
    }
}

