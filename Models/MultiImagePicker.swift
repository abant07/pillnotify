//
//  MultiImagePicker.swift
//  PillAlertify
//
//  Created by Amogh Bantwal on 9/6/23.
//

import Foundation
import SwiftUI
import PhotosUI

// allows the user to pick mutiple images from their camara roll on a sheet
class MultiImagePickerCoordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    @Binding var images: [UIImage]
    @Binding var isShown: Bool
    
    init(images: Binding<[UIImage]>, isShown: Binding<Bool>) {
        _images = images
        _isShown = isShown
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.images.append(image)
                        }
                    }
                }
            }
        }
        
        isShown = false
    }
    
    func pickerDidCancel(_ picker: PHPickerViewController) {
        isShown = false
    }
}

struct MultiImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    typealias Coordinator = MultiImagePickerCoordinator
    
    @Binding var images: [UIImage]
    @Binding var isShown: Bool
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<MultiImagePicker>) {
    }
    
    func makeCoordinator() -> MultiImagePicker.Coordinator {
        return MultiImagePickerCoordinator(images: $images, isShown: $isShown)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MultiImagePicker>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.selectionLimit = 0  // 0 means no limit (select as many images as desired)
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
}
