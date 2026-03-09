//
//  ContentView.swift
//  ToDoListCreated2
//
//  Created by Кристина Игоревна on 22.06.2025.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @AppStorage("isDark") private var isDarkMode: Bool = false
    @State var placeholderText: String = ""
    @State private var viewModel: TaskViewModel = TaskViewModel()
    @Environment(\.modelContext) private var modelContext
    private var isAddButtonDisabled: Bool {
        placeholderText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Text("Мои задачи")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Text("Главное - начать.")
                    .modifier(SubTitle())
                
                HStack {
                    TextField("Новая задача", text: $placeholderText) //State -> Binding
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .onChange(of: placeholderText) { newValue in
                            if newValue.first == " " {
                                placeholderText = String(newValue.dropFirst())
                                return
                            }
                            placeholderText = newValue.filter { $0.isLetter || $0.isWhitespace || $0.isNumber }
                        }
                    
                    Button {
                        // Проверка на пустое значение
                        if !placeholderText.isEmpty {
                            viewModel.teskAdd(title: placeholderText)
                            placeholderText = ""
                            
                        }
                        
                    } label: {
                        Text("+")
                            .modifier(ButtonPlus())
                            .opacity(isAddButtonDisabled ? 0.5 : 1)
                    }
                }
                
                List {
                    ForEach(viewModel.taskHolderGar) { task in
                        HStack{
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" :  "circle")
                                .foregroundStyle(task.isCompleted ? .green : .gray)
                                .onTapGesture {
                                    viewModel.toggleComplited(task: task)
                                }
                            Text(task.title)
                                .strikethrough(task.isCompleted, color: .black)
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(PlainListStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear() { viewModel.setUp(modelContext: modelContext) }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        
    }
    
    private func deleteTask(at offsets: IndexSet) {
        viewModel.deleteTask(at: offsets) // Вызов метода удаления из ViewModel
    }
}


//канвас
#Preview { MainView() }



