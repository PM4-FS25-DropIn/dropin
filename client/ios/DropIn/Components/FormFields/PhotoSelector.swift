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
        }
    }
}

#Preview {
    PhotoSelector(selectedPhotos: .constant([]), text: "Add Photos")
}
