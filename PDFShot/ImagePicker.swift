//
//  ImagePicker.swift
//  Shareshot
//
//  Created by Chris Coffin on 12/17/20.
//

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
	@Binding var images: [UIImage]
	@Binding var isShowing: Bool
	@Binding var nonPNGFilesSelected: Bool
	
	func makeCoordinator() -> Coordinator {
		return ImagePicker.Coordinator(fromParent: self)
	}
	
	func makeUIViewController(context: Context) -> PHPickerViewController {
		var configuration = PHPickerConfiguration()
		configuration.selectionLimit = 0
		configuration.filter = .images
		configuration.preferredAssetRepresentationMode = .current
		let picker = PHPickerViewController(configuration: configuration)
		picker.delegate = context.coordinator
		
		return picker
	}
	
	func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
	
	class Coordinator: NSObject, PHPickerViewControllerDelegate {
		var parent: ImagePicker
		
		init(fromParent: ImagePicker) {
			parent = fromParent
		}
		
		func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
			parent.isShowing.toggle()
			
			if !parent.images.isEmpty {
				parent.images = []
			}
			
			for image in results {
				if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
					if image.itemProvider.registeredTypeIdentifiers[0] == "public.png" {
						image.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
							guard let image1 = image else {
								return
							}
							self.parent.images.append(image1 as! UIImage)
						}
					} else {
						self.parent.nonPNGFilesSelected = true
					}
				}
			}
		}
	}
}
