//
//  SessionHistoryWelcomeView.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import SwiftUI

struct SessionHistoryWelcomeView: View {
    @State var dataVm = DataService()
    let user: User = User.sample
    @State var userSessions: [Interview] = []
    @State private var refreshID = UUID()
    var body: some View {
        NavigationStack {
            VStack {
                if userSessions.count > 0 {
                    List(userSessions) { session in
                        NavigationLink(destination: InterviewSessionSummaryDetailView(session: session)) {
                            
                            InterviewSessionCardView(session: session)
                        }
                    }
                }
            }
            .id(refreshID)
            .navigationTitle("Your recent Interviews")
            .onAppear {
                Task {
                    userSessions = await dataVm.getUserSessions(uid: user.uid)
                }
            }
        }

    }
}

#Preview {
    SessionHistoryWelcomeView()
}
