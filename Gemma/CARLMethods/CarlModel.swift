//
//  CarlModel.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import Foundation

import FirebaseStorage


struct CarlMethod: Identifiable, Codable {
    var id: String { docId }
    var docId: String
    let title: String
    var context: String
    var action: String
    var result: String
    var learning: String
    var createdAt: Date
    
    
    init(docId: String, title: String, context: String, action: String, result: String, learning: String, createdAt: Date) {
        self.title = title
        self.context = context
        self.action = action
        self.result = result
        self.learning = learning
        self.docId = docId
        self.createdAt = createdAt
    }
}




extension CarlMethod {
    static let sampleData: CarlMethod = CarlMethod(docId: "", title: "Title of Log", context: "Context 1", action: "Action 1", result: "Result 1", learning: "Learning 1", createdAt: Date())
}
