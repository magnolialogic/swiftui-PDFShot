//
//  ReviewSelectionView.swift
//  PDFShot
//
//  Created by Chris Coffin on 12/17/20.
//

import SwiftUI
import PDFKit

struct ReviewSelectionView: View {
	@Binding var images: [UIImage]
	@Binding var isPresentingLoadingView: Bool
	@Binding var nonPNGFilesSelected: Bool
	
	@State private var selectedSize = 0
	@State private var commentText = ""
	@State private var includeInfo = true
	
	let fontSize: CGFloat = 14
	let buttonVPadding: CGFloat = 8
	let buttonHPadding: CGFloat = 16
	
	var body: some View {
		VStack(alignment: .center) {
			Spacer()
			
			ScrollView(.horizontal, showsIndicators: false, content: {
				if images.count == 1 {
					Image(uiImage: images[0])
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(height: 256)
						.cornerRadius(20)
				} else {
					HStack(alignment: .center, spacing: 16) {
						Spacer()
						
						ForEach(images, id: \.self) { image in
							Image(uiImage: image)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(height: 256)
								.cornerRadius(20)
						}
					}
				}
			})
			
			Spacer()
			
			HStack {
				Text("Comments")
					.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
				TextField("Optional", text: $commentText)
					.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 20))
			}
			
			Toggle(isOn: $includeInfo) {
				Text("Include device + OS version")
			}
			.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
			
			Spacer()
			
			Button(action: {
				isPresentingLoadingView = true
				var attachments = [Any]()
				let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
				let pdfURL = documentsDirectoryURL.appendingPathComponent("Screenshots.pdf")
				do {
					if FileManager.default.fileExists(atPath: pdfURL.path) {
						try FileManager.default.removeItem(at: pdfURL)
					}
				} catch {
					print("Failed to clean up directory: \(error)")
				}
				
				DispatchQueue.global(qos: .background).async {
					let screenshotsPDF = PDFDocument()
					
					for index in images.indices {
						let pdfPage = PDFPage(image: images[index].scalePreservingAspectRatio(target: 360))
						screenshotsPDF.insert(pdfPage!, at: index)
					}
					
					let pdfData = screenshotsPDF.dataRepresentation()
					
					do {
						try pdfData?.write(to: pdfURL)
						attachments.append(pdfURL)
						if includeInfo {
							print(UIDevice().type.rawValue)
							attachments.append("Device: \(UIDevice().type.rawValue)")
							attachments.append("OS Version: \(UIDevice.current.systemVersion)")
						}
						if commentText != "" {
							attachments.append("Comment: " + commentText)
						}
						DispatchQueue.main.async {
							isPresentingLoadingView = false
							var subject: String
							if images.count == 1 {
								subject = "PDFShot: 1 screenshot"
							} else {
								subject = "PDFShot: \(images.count) screenshots"
							}
							let activityViewController = UIActivityViewController(activityItems: attachments, applicationActivities: nil)
							activityViewController.setValue(subject, forKey: "Subject")
							UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
						}
					} catch(let error) {
						print("Failed to write PDF: \(error.localizedDescription)")
					}
				}
				
//				if UIDevice.current.userInterfaceIdiom == .pad {
//					activityViewController.popoverPresentationController?.sourceView = UIView(frame: geometry.frame(in: .global))
//				}
			}, label: {
				Image(systemName: "square.and.arrow.up")
					.font(.system(size: 26))
			})
			
			Spacer()
		}
	}
}
