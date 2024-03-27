//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Maksim  on 27.03.2024.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    let formatteDate: String
    
    func isBetterThan(_ another: GameRecord) -> Bool {
        return correct > another.correct
    }
}

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Properties
    private var gameRecords: [GameRecord] {
        get {
            guard let data = userDefaults.data(forKey: Keys.gameRecords),
                  let records = try? JSONDecoder().decode([GameRecord].self, from: data) else {
                return []
            }
            return records
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Unable to save game records.")
                return
            }
            
            userDefaults.set(data, forKey: Keys.gameRecords)
        }
    }
    
    var totalAccuracy: Double {
        get {
            guard !gameRecords.isEmpty else {
                print("No game records found.")
                return 0
            }
            let totalCorrect = gameRecords.reduce(0) { $0 + $1.correct }
            let totalQuestions = gameRecords.reduce(0) { $0 + $1.total }
            let accuracy = Double(totalCorrect) / Double(totalQuestions) * 100.0
            print("Total accuracy calculated: \(accuracy)")
            return accuracy
        }
    }
    
    var gamesCount: Int {
        get { return gameRecords.count }
    }
    
    var bestGame: GameRecord {
        get {
            guard let bestRecord = gameRecords.max(by: { $0.correct < $1.correct }) else {
                let currentDate = Date()
                let formatteDate = currentDate.dateTimeString
                return GameRecord(correct: 0, total: 0, date: currentDate, formatteDate: formatteDate)
            }
            return bestRecord
        }
    }
    
    // MARK: - Methods
    func store(correct count: Int, total amount: Int) {
        let currentDate = Date()
        let formatteDate = currentDate.dateTimeString
        let record = GameRecord(correct: count, total: amount, date: currentDate, formatteDate: formatteDate)
        var updatedRecords = gameRecords
        updatedRecords.append(record)
        gameRecords = updatedRecords
        print("Saved new game record: \(record)")
    }
    
    init() {
        print("Initializing StatisticServiceImplementation")
        _ = gameRecords
        print("Loaded game records: \(gameRecords)")
    }
}

