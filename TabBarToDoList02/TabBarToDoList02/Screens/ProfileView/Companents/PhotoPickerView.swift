import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    
    var body: some View {
        VStack {
            if let uiImage = selectedUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150) // Квадратные размеры для идеального круга
                    .clipShape(Circle()) // Делаем изображение круглым
                    .overlay(Circle().stroke(Color.white, lineWidth: 4)) // Опционально: белая обводка
                                        .shadow(radius: 10) // Опционально: тень
            }
            
            PhotosPicker("Выбрать фото", selection: $selectedItem, matching: .images)
        }
        .task(id: selectedItem) {
            await loadImage()
        }
        .padding()
    }
    
    func loadImage() async {
        guard let selectedItem else { return }
        do {
            if let data = try await selectedItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedUIImage = uiImage
            }
        } catch {
            print("Ошибка загрузки изображения: \(error)")
        }
    }
}

