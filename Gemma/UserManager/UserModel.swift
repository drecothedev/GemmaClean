//
//  UserModel.swift
//  Gemma
//
//  Created by Andre jones on 4/4/25.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    var id: String { uid }
    let uid: String
    let displayName: String
    let totalSessions: Int
    let averageScore: Double
    let goals: [String]
    let feedBackPoints: [String]
    var carls: [CarlMethod]
    
    var interviewSessions: [Interview]?
    
    init(uid: String, displayName: String, totalSessions: Int, averageScore: Double, goals: [String], feedBackPoints: [String], carls: [CarlMethod]) {
        self.uid = uid
        self.displayName = displayName
        self.totalSessions = totalSessions
        self.averageScore = averageScore
        self.goals = goals
        self.feedBackPoints = feedBackPoints
        self.carls = carls
    }
}



extension User {
    static var sample: User {
        User(
            uid: "vSxce5pmj6rWKX0F5yJA",
            displayName: "johnnyGetDough",
            totalSessions: 0,
            averageScore: 0,
            goals: [],
            feedBackPoints: [],
            carls: []
        )
    }
}

