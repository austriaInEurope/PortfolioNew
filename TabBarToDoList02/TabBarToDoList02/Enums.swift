//
//  Enums.swift
//  TabBarToDoList02
//
//  Created by Кристина Игоревна on 20.07.2025.
//

import Foundation
import SwiftUI

enum ImageState {
    case empty
    case loading
    case success(Image)
    case failure(String) 
}
