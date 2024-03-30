//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Maksim  on 27.03.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
