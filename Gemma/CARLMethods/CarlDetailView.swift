//
//  CarlDetailView.swift
//  Gemma
//
//  Created by Andre jones on 4/6/25.
//

import SwiftUI

struct CarlDetailView: View {
    var carl: CarlMethod

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(carl.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    detailRow(label: "Context", value: carl.context)
                    detailRow(label: "Action", value: carl.action)
                    detailRow(label: "Result", value: carl.result)
                    detailRow(label: "Learning", value: carl.learning)
                    
                    HStack {
                        Spacer()
                        Text("Created: \(carl.createdAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding()
            }
            .navigationTitle("CARL Entry")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}


#Preview {
    CarlDetailView(carl: CarlMethod(
        docId: "1",
        title: "Led Standup",
        context: "Team had low engagement in sprint reviews.",
        action: "Facilitated daily standups with focused agendas.",
        result: "Increased participation by 60%.",
        learning: "Small structure changes can greatly improve team engagement.",
        createdAt: Date()
    ))
}




