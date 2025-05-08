//
//  PhotoSelector.swift
//  dropin
//
//  Created on 01/05/2025.
//


import SwiftUI
import PhotosUI

struct PhotoSelector: View {
    @Binding var selectedPhotos: [PhotosPickerItem]
    
    var text: String
    
    var body: some View {
        PhotosPicker(selection: $selectedPhotos,
                     matching: .images) {
            Text(text)
                .font(.title3)
                .bold()
                .foregroundStyle(.accent)
        }
    }
}

#Preview {
    PhotoSelector(selectedPhotos: .constant([]), text: "Add Photos")
}
