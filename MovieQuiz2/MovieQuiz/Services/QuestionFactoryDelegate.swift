//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Maksim  on 26.03.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}

