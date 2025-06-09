//
//  ActiveInterviewView.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import SiriWaveView
import SwiftUI


struct ActiveInterviewView: View {
    @EnvironmentObject var interviewVm: InterviewService
    @Environment(\.colorScheme) var colorScheme
    @State var isSymbolAnimating = false
    @State private var navigateToIterviewFeedback: Bool = false
    @State private var showFeedbackButton: Bool = false
    @State private var isThumbsUpPulsing: Bool = false
    @State var showHints: Bool = false
    @State private var isAnimating: Bool = false
    
    

    
    var body: some View {
        NavigationStack {
            VStack {
                SiriWaveView(power: $interviewVm.audioPower)
                    .opacity(interviewVm.siriWaveFormOpacity)
                    .overlay { overlayView }
                if interviewVm.isInterviewActive {
                    Text("Question \(interviewVm.currentQuestionIndex + 1)/\(interviewVm.questions.count)")
                }
                
                switch interviewVm.state {
                case .recording:
                    cancelRecordingButton
                case .playing, .processing:
                    cancelTaskButton
                default: EmptyView()
                }
                if showFeedbackButton {
                    getFeedbackButton
                    
                    NavigationLink(destination: CompletedInterviewView(),
                                   isActive: $navigateToIterviewFeedback) {
                        EmptyView()
                    }
                }
            }.sheet(isPresented: $showHints) {
                CarlsListView(showHints: $showHints)
            }
            .toolbar {
                Button() {
                    showHints.toggle()
                } label: {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(colorScheme == .dark ? .bubblegum : .blue)
                }
            }
        }
    }
    @ViewBuilder
    var overlayView: some View {
        switch interviewVm.state {
        case .idle, .error:
            startCaptureButton
            
            
        case .finished:
            VStack {
                Text("Your interview is complete!")
                    .font(.caption)
                    .padding()
                Image("ThumbsUp")
                    .resizable()
                    .frame(width: 128, height: 128)
                    .scaleEffect(isThumbsUpPulsing ? 1.05 : 0.95)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                   value: isThumbsUpPulsing
                    )
            }.onAppear {
                isThumbsUpPulsing = true
            }
            
            
        case .processing:
            VStack {
                Image(systemName: "brain")
                    .foregroundStyle(.bubblegum)
                    .symbolEffect(.bounce.up.byLayer, value: isSymbolAnimating)
                    .font(.system(size: 128))
                    .onAppear {
                        isSymbolAnimating = true
                    }
                    .onDisappear {
                        isSymbolAnimating = false
                    }
                Text("Your interviewer is processing your feedback...")
                    .font(.caption)
                    .padding()
            }
        default: EmptyView()
        }
    }
    
    var startCaptureButton: some View {
        Button {
            if interviewVm.isIdle {
                interviewVm.startCapture()
                showFeedbackButton = true
            } else {
                interviewVm.cancelRecording()
            }
        } label: {
            Text(interviewVm.isIdle ? "Start Answer" : "Cancel")
                .padding()
                .frame(width: 200, height: 50)
                .background(interviewVm.isIdle ? Color.cyan : Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
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
    
    var cancelRecordingButton: some View {
        Button(role: .destructive){
            interviewVm.cancelRecording()
            
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.red)
                .font(.system(size: 50))
        }.buttonStyle(.borderless)
    }
    
    var cancelTaskButton: some View {
        Button(role: .destructive) {
            interviewVm.cancelProcessingTask()
            
        } label: {
            Image(systemName: "stop.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.red)
                .font(.system(size: 50))
        }.buttonStyle(.borderless)
    }
    
    var getFeedbackButton: some View {
        Button() {
            interviewVm.interviewComplete = true
            
            Task {
                await interviewVm.performFeedback()
            }
            showFeedbackButton = true
            navigateToIterviewFeedback = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 200, height: 50)
                    .foregroundStyle(.cyan)
                Text("Get Feedback")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    ActiveInterviewView()
        .environmentObject(InterviewService())
  
}


