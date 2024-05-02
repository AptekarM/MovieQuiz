//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Maksim  on 30.03.2024.
//
import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
    
    var hasError: Bool {
        return !errorMessage.isEmpty
    }
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    var resizedImageURL: URL {
        let urlString = imageURL.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        
        return newURL
    }
    
    private enum CodingKeys : String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}

func main() {
    let jsonData = """
    {
        "errorMessage": "API key просрочен",
        "items": []
    }
    """.data(using: .utf8)!

    do {
        let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: jsonData)
        
        if mostPopularMovies.hasError {
            let errorMessage = mostPopularMovies.errorMessage.lowercased()
            if errorMessage.contains("api key неверный") {
                // Показать пользователю алерт о неверном ключе API
                print("Invalid API key. Please check your API key.")
            } else if errorMessage.contains("api key просрочен") {
                // Показать пользователю алерт о просроченном ключе API
                print("Expired API key. Please renew your API key.")
            } else if errorMessage.contains("количество запросов в день превышено") {
                // Показать пользователю алерт о превышении лимита запросов
                print("Daily request limit exceeded. Please try again later.")
            } else {
                // Другие случаи ошибок
                print("Unknown error: \(mostPopularMovies.errorMessage)")
            }
        } else {
            // Продолжить обработку списка фильмов
            print("No error. Proceed with movie list.")
        }
    } catch {
        print("Error decoding JSON: \(error)")
    }
}

