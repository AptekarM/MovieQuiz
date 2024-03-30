//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Maksim  on 26.03.2024.
//

import Foundation

// Структура для представления вопроса в квизе
struct QuizQuestion {
    // Строка с названием фильма, совпадает с названием картинки афиши фильма в Assets
    let image: String
    // Строка с вопросом о рейтинге фильма
    let text: String
    // Булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}
