import SwiftUI
import PhotosUI

struct AccountView: View {
    @State private var phoneNumber: String = "+7 (999) 123-45-67"
    @State private var email: String = "example@mail.com"
    @State private var showingEditSheet = false
    @State private var showingLogoutAlert = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    
    var body: some View {
        ZStack {
            ZStack {
                VStack(spacing: 20) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        if let profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.blue)
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        }
                    }
                    .padding(.top, 40)
                    .task(id: selectedPhotoItem) {
                        do {
                            if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                profileImage = image
                            }
                        }
                    }
                    
                    VStack(spacing: 15) {
                        InfoField(
                            icon: "phone.fill",
                            title: "Телефон",
                            value: phoneNumber
                        )
                        Divider()

                        InfoField(
                            icon: "envelope.fill",
                            title: "Почта",
                            value: email
                        )
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    
                    Spacer()
                    
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Text("Редактировать профиль")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            
                    }
                    .sheet(isPresented: $showingEditSheet) {
                        EditAccountView(phoneNumber: $phoneNumber, email: $email)
                    }
                    
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Выйти из аккаунта")
                        }
                        .foregroundColor(.red)
                        .padding()
                    }
                    .alert("Подтвердите выход", isPresented: $showingLogoutAlert) {
                        Button("Отмена", role: .cancel) {}
                        Button("Выйти", role: .destructive) {
                        }
                    } message: {
                        Text("Вы уверены, что хотите выйти из своего аккаунта?")
                    }
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .navigationTitle("Мой аккаунт")
            .navigationBarTitleDisplayMode(.inline)
            
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}


struct InfoField: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct EditAccountView: View {
    @Binding var phoneNumber: String
    @Binding var email: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Контактные данные") {
                    TextField("Телефон", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AccountView()
}
