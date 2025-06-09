//
//  StartInterview.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import SwiftUI

struct StartInterviewWelcomeView: View {

    @EnvironmentObject var interviewVM: InterviewService
    @State private var isAnimating: Bool = false
    @State private var selectectedVoice: VoiceType = .alloy
    let user = User.sample

    
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Spacer()
                Image("PeaceFace")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.01 : 0.99)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                Text("Practice answering real interview questions with voice and receive AI-generated feedback to improve your skills.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                
                NavigationLink {
                    SetInterviewParametersView()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 200, height: 50)
                            .foregroundStyle(Color.cyan)
                        Text("Start")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            
                    }
                    .padding()
                    .scaleEffect(isAnimating ? 1.05 : 0.95)
                        .animation(
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                .onAppear {
                    isAnimating = true
                }
            }
            .navigationTitle("🎙️ AI Mock Interview")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Select Voice", selection: $interviewVM.newSelectedVoice) {
                            ForEach(VoiceType.allCases, id: \.self) { voice in
                                Text(voice.rawValue.capitalized).tag(voice)
                            }
                        }
                    } label: {
                        Label("Theme", systemImage: "waveform.and.person.filled")
                    }
                }
            }
            .onChange(of: interviewVM.newSelectedVoice) { newVoice in
                Task {
                    await interviewVM.playVoiceSample(for: newVoice)
                }
            }

        }
    }
}

#Preview {
    StartInterviewWelcomeView()
}
