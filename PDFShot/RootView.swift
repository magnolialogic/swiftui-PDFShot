//
//  RootView.swift
//  PDFShot
//
//  Created by Chris Coffin on 12/15/20.
//

import SwiftUI

struct RootView: View {
	@State var images: [UIImage] = []
	
	@State var isPresentingAlert = false
	@State var isPresentingImagePicker = false
	@State var isPresentingLoadingView = false
	@State var isZipping = false
	@State var nonPNGFilesSelected = false
	
	func propagateError() {
		isPresentingAlert = nonPNGFilesSelected
		nonPNGFilesSelected = false
	}
	
	var body: some View {
		LoadingView(isShowing: $isPresentingLoadingView) {
			NavigationView {
				VStack {
					if images.isEmpty {
						Text("No images selected")
					} else {
						ReviewSelectionView(images: $images, isPresentingLoadingView: $isPresentingLoadingView, nonPNGFilesSelected: $nonPNGFilesSelected)
					}
				}
				.navigationBarTitle("PDFShot")
				.navigationBarTitleDisplayMode(.inline)
				.navigationBarItems(trailing: Button(action: {
					if images.isEmpty {
						images = []
						nonPNGFilesSelected = false
						isPresentingImagePicker.toggle()
					} else {
						images = []
						nonPNGFilesSelected = false
					}
				}, label: {
					if images.isEmpty {
						Image(systemName: "plus")
							.imageScale(.large)
					} else {
						Image(systemName: "trash")
							.imageScale(.large)
							.foregroundColor(.red)
					}
					
				}))
			}
			.alert(isPresented: $isPresentingAlert) {
				Alert(
					title: Text("Warning"),
					message: Text("Ignored non-PNG images in selection."),
					dismissButton: .default(Text("OK"))
				)
			}
			.sheet(isPresented: $isPresentingImagePicker, onDismiss: propagateError) {
				ImagePicker(images: $images, isShowing: $isPresentingImagePicker, nonPNGFilesSelected: $nonPNGFilesSelected)
			}
		}
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView()
	}
}
