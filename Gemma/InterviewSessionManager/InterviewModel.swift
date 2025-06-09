//
//  InterviewModel.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import Foundation
import FirebaseFirestore


struct Interview: Codable, Identifiable{
    var id: String { docId }
    let docId: String
    var name: String
    var role: String
    var createdAt: Date
    var grade: Double?
    var feedback: String?
    var completed: Bool
    var keyWords: [String]
    
    init(docId: String, name: String, role: String, createdAt: Date, grade: Double, feedback: String?, completed: Bool, keyWords: [String]) {
        self.docId = docId
        self.name = name
        self.role = role
        self.createdAt = createdAt
        self.grade = grade
        self.feedback = feedback
        self.completed = completed
        self.keyWords = keyWords
    }
}


extension Interview {
    static var emptyForm: Interview {
        Interview(docId: "", name: "", role: "", createdAt: Date(), grade: 0.0, feedback: "", completed: false, keyWords: [])
    }
}

extension Interview {
    static var sampleSession: Interview {
        Interview(docId: "1", name: "Interview for Tech Role", role: "Tech Specialist", createdAt: Date(), grade: 0.0, feedback: """
            Really good interview Practice keep up man. I found that you were exceptional in these areas but may want to look to improve if you really want this role. 
            """,
            completed: false, keyWords: ["Driven", "Motivated", "Passionate"])
    }
}

