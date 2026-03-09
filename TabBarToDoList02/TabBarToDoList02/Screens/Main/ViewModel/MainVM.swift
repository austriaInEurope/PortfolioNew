//
//  MainVM.swift
//  ToDoListCreated2
//
//  Created by Кристина Игоревна on 22.06.2025.
//

import Foundation
import SwiftData


@MainActor
@Observable
class TaskViewModel  {
    var taskHolderGar: [Task] = []
    private var modelContext: ModelContext?
    
    
    func setUp(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchTasks()
    }
    
    
    func fetchTasks() {
        guard let modelContext else { return }
        do {
            let descriptor: FetchDescriptor<Task> = FetchDescriptor<Task>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            taskHolderGar = try modelContext.fetch(descriptor)
            print("taskHolderGarFetch: ", taskHolderGar)
        } catch {
            print("модель не смогла создаться:  ", error )
        }
    }
    
    
    func teskAdd(title: String) {
        guard let modelContext, !title.isEmpty else { return }
        let task: Task = Task(title: title)
        print(task)
        modelContext.insert(task)
        do {
            try modelContext.save()
            taskHolderGar.insert(task, at: 0)
        } catch {
            print("ошибка сохранения: ", error)
        }
        saveContext()
    }

    
    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let taskToDelete = taskHolderGar[index]
            modelContext?.delete(taskToDelete)
        }
        taskHolderGar.remove(atOffsets: offsets)
        saveContext()
    }

    
    func toggleComplited(task: Task) {
        guard let modelContext else { return }
        task.isCompleted.toggle()
        saveContext()
    }
    

    private func saveContext() {
        do {
            try modelContext?.save()
        } catch {
            print("Ошибка сохранения: \(error.localizedDescription)")
        }
    }
}


