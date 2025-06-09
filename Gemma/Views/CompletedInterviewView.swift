//
//  CompletedInterviewView.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import SwiftUI

struct CompletedInterviewView: View {
    @EnvironmentObject var interviewVm: InterviewService
    @State var user: User = User.sample
    @State var feedback: String = "Great job! we are processing your interview for feedback please wait a second or two..."
    
    @State private var navigate: Bool = false
    

    var body: some View {
        
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Text("🎉 Interview Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("You just completed a mock interview for:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(interviewVm.role)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("📋 AI Feedback")
                        .font(.headline)
                    
                    ScrollView {
                        Text(feedback)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .frame(height: 200)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        navigate = true
                        Task {
                            await interviewVm.uploadSessionToFirestore(uid: user.uid)
                        }
                    }) {
                        Text("Back to Home")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cyan)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    NavigationLink(destination: ContentView(),
                                   isActive: $navigate
                    ) {
                        EmptyView()
                    }.navigationBarBackButtonHidden(true)
                    
                }
                .padding(.horizontal)
            }
            .background(ConfettiView())
            .padding()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                Task {
                    feedback = await interviewVm.performFeedback()
                }
                
            }
        }
    }
}

#Preview {
    CompletedInterviewView()
        .environmentObject(InterviewService())

}
