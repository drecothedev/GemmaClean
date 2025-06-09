//
//  InterviewSessionSummaryDetailView.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import SwiftUI

struct InterviewSessionSummaryDetailView: View {
    var session: Interview

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("🧑‍💻 Role")
                    .font(.headline)
                Text(session.role)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("🔑 Keywords Mentioned")
                    .font(.headline)

                if session.keyWords.isEmpty {
                    Text("No keywords recorded.")
                        .foregroundColor(.gray)
                } else {
                    List(session.keyWords, id: \.self) { keyword in
                        Text(keyword)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.cyan.opacity(0.2))
                            .cornerRadius(12)
                    }
                }

                Text("📋 AI Feedback")
                    .font(.headline)
                if let feedback = session.feedback {
                    Text(feedback)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                HStack {
                    Spacer()
                    Text("Completed on \(session.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding()
        }
        .navigationTitle("Interview Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    InterviewSessionSummaryDetailView(session: User.sample.interviewSessions?[0] ?? Interview.emptyForm)
}


