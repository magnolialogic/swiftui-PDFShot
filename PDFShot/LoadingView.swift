//
//  LoadingView.swift
//  Shareshot
//
//  Created by Chris Coffin on 12/21/20.
//  https://roddy.io/2020/07/27/create-progressview-modal-in-swiftui/
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {
	
	@Binding var isShowing: Bool
	var content: () -> Content
	var text: String?
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				content()
					.disabled(isShowing)
					.blur(radius: isShowing ? 2 : 0)
				
				if isShowing {
					Rectangle()
						.fill(Color.primary).opacity(isShowing ? 0.15 : 0)
						.edgesIgnoringSafeArea(.all)
					
					VStack(spacing: 24) {
						ProgressView().scaleEffect(2.0)
						Text(text ?? "Creating PDF...").font(.title3).fontWeight(.semibold)
					}
					.frame(width: 200, height: 200)
					.background(Color(UIColor.systemBackground))
					.foregroundColor(Color.primary)
					.cornerRadius(20)
				}
			}
		}
	}
}
