//
//  NEW.swift
//  TestApp
//
//  Created by Игорь Крысин on 20.07.2025.
//
// Состояния изображения

import SwiftUI
import PhotosUI

class ProfileViewModel: ObservableObject {
    @Published var showImagePicker: Bool = false
    @Published var selectedImage: Image? = nil
    @Published var imageState: ImageState = .empty
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet { // наблюдение за изменениями ImageSelection
            if let imageSelection {
                loadImage(from: imageSelection)
                print("imageSelection:", imageSelection)
            }
        }
    }
    
    
    private func loadImage(from imageSelection: PhotosPickerItem) {
        imageState = .loading
        
        DispatchQueue.global(qos: .userInitiated).async {
            imageSelection.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let data = data, let uiImage = UIImage(data: data) {
                            self.imageState = .success(Image(uiImage: uiImage))
                        } else {
                            self.imageState = .failure("Не удалось загрузить изображение")
                        }
                    case .failure(let error):
                        self.imageState = .failure(error.localizedDescription)
                    }
                }
            }
        }
    }
}

