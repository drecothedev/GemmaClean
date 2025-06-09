//
//  DataViewModel.swift
//  Gemma
//
//  Created by Andre jones on 4/4/25.
//

import FirebaseCore
import FirebaseFirestore
import Foundation


public class DataViewModel: ObservableObject {
    @Published var user: User?
    
    
    func getUserFromDisplay(displayName: String) {
        Task {
            do {
                print("Grabbing User: \(displayName)")
                try await DataService.shared.getUserFromDisplayName(displayName: displayName)
                
            } catch {
                print("Error grabbing user: \(displayName)")
                return
                
            }
        }
    }
    
    
    func getUserFromUid(uid: String) {
        Task {
            do {
                print("Grabbing User: \(uid)")
                try await DataService.shared.getUserFromDisplayName(displayName: uid)
                
            } catch {
                print("Error grabbing user: \(uid)")
                return
                
            }
        }
    }
    
    
    func getUserCarls(uid: String) async -> [CarlMethod] {
        return await DataService.shared.getUserCarls(uid: uid)
    }
    
    func postCarl(uid: String, carl: CarlMethod) async {
        Task {
            await DataService.shared.pushCarlDataToDatabase(uid: uid, carl: carl)
        }
    }
    
    func getInterviewSessions(uid: String) async -> [Interview] {
        return await DataService.shared.getUserSessions(uid: uid)
    }
}
