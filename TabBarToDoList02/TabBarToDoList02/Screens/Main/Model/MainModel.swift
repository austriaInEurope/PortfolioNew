//
//  MainModel.swift
//  ToDoListCreated2
//
//  Created by Кристина Игоревна on 22.06.2025.
//

import Foundation
import SwiftData

@Model
final class Task {
    var title: String = ""
    var isCompleted: Bool
    var createdAt: Date
    
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}



