//
//  DataManager.swift
//  Gemma
//
//  Created by Andre jones on 4/4/25.
//

import Foundation
import Firebase
import FirebaseCore

final class DataService: ObservableObject {
    static let shared = DataService()
    private var db = Firestore.firestore()
    
    
    
    func getUserFromDisplayName(displayName: String) async throws {
        do {
            print("Finding info for user: \(displayName)")
            let dataTaskResult = try await db.collection("users").whereField("displayName", isEqualTo: displayName).getDocuments()
            
        
            for document in dataTaskResult.documents {
                var data = document.data()
            }
            
        } catch  {
            print("Unable to get users")
        }
    }
    
    // PREFERED METHOD FOR RETREIVING USER
    func getUserFromId(uid: String) async throws {
        
        do {
            print("Finding info for user: \(uid) ...")
            let dataTaskResult = try await db.collection("users").document(uid).getDocument()
            
            if let data = dataTaskResult.data() {
                print("Creating user model from \(uid) ...")
                let userModel = User(uid: dataTaskResult.documentID as? String ?? "",
                                     displayName: data["displayName"] as? String ?? "",
                                     totalSessions: data["totalSessions"] as? Int ?? 1000,
                                     averageScore: data["averageScore"]as? Double ?? 0.0,
                                     goals: data["goals"] as? [String] ?? [],
                                     feedBackPoints: data["feedBackPoints"] as? [String] ?? [],
                                     carls: data["carls"] as? [CarlMethod] ?? [])
                
                print("User found and converted successfully: ", userModel)
            } else {
                print("No data found for user: \(uid)")
            }
        }
    }
    
    
    func getUserCarls(uid: String) async -> [CarlMethod] {
        var carlModel: CarlMethod?
        var carlArr: [CarlMethod] = []

        do {
            print("Finding carls for user \(uid)...")
            
            let dataTaskResult = try await db.collection("users")
                .document(uid)
                .collection("carls")
                .getDocuments()
            
            print("Documents count: \(dataTaskResult.documents.count)")
            
            for doc in dataTaskResult.documents {
                let data = doc.data()
                carlModel = CarlMethod(
                    docId: doc.documentID,
                    title: data["title"] as? String ?? "",
                    context: data["context"] as? String ?? "",
                    action: data["action"] as? String ?? "",
                    result: data["result"] as? String ?? "", // Make sure the field is capitalized exactly like this in Firestore
                    learning: data["learning"] as? String ?? "",
                    createdAt: data["createdAt"] as? Date ?? Date()
                )
                
                carlArr.append(carlModel!)
                print(carlArr)
            }
            return carlArr
            
        } catch {
            print("Error finding carls: \(error)")
            return []
        }
    }
    
    
    func pushCarlDataToDatabase(uid: String, carl: CarlMethod) async {
        let carlData: [String : Any] = [
            "title" : carl.title,
            "context" : carl.context,
            "action" : carl.action,
            "result" : carl.result,
            "learning" : carl.learning,
            "createdAt" : carl.createdAt
            
        ]
        do {
            print("Pushing data to db...")
            let _ = try await db.collection("users").document(uid).collection("carls").document(carl.docId).setData(carlData)
            let findNewCarl = try await db.collection("users").document(uid).collection("carls").getDocuments()
            for document in findNewCarl.documents {
                print("\(document.documentID) => \(document.data())")
            }
            print("Successfully pushed data to database!")
        } catch {
            print("Error posting Carl data to database:\(error.localizedDescription)")
        }
            
            
    }
    
    
    
    func getUserSessions(uid: String) async -> [Interview] {
        var interviewSessions: [Interview] = []
        
        do {
            let dataTask = try await db.collection("users").document(uid).collection("interview_sessions").getDocuments()
            
            for document in dataTask.documents {
                let data = document.data()
                
                var session = Interview(
                    docId: document.documentID,
                    name: data["name"] as? String ?? " ",
                    role: data["role"] as? String ?? "",
                    createdAt: data["createdAt"] as? Date ?? Date(),
                    grade: data["grade"] as? Double ?? 0.0,
                    feedback: data["feedback"] as? String ?? "",
                    completed: true,
                    keyWords: data["keywords"] as? [String] ?? [] // ← note lowercase key
                )
                
                session.name = "Interview for \(session.role)"
                interviewSessions.append(session)
            }
            
            return interviewSessions
        } catch {
            print("Error grabbing user sessions for user \(uid): \(error)")
            return []
        }
    }

}

