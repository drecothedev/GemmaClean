//
//  InterviewService.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import AVFoundation
import FirebaseFirestore
import Foundation

enum InterviewState {
    case idle
    case active
    case finished
    case error(Error)
}


@MainActor
class InterviewService: AIVoiceService, ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var isInterviewActive = false
    @Published var interviewComplete = false
    @Published var role: String = ""
    @Published var keyWords: [String] = []
    @Published var newSelectedVoice: VoiceType = .alloy
    
    var currentConvo: [String: String] = [:]
    
    var interviewFeedBack: String = ""
    var currentInterviewSession: Interview = Interview.emptyForm
    
    
    
    var questions =  [
        "Tell me about a time you handled a challenging situation at work.",
        "How do you approach learning a new technology?",
        "Can you describe a time when you led a team?"                                                                           
    ]
    
    
    
    func startInterview() {
        currentQuestionIndex = 0
        isInterviewActive = true
        interviewComplete = false
        askNextInterviewQuestion()
    }
    
    func askNextInterviewQuestion() {
        guard currentQuestionIndex < questions.count else {
            isInterviewActive = false
            interviewComplete = true
            askQuestion(question: "Great work! That concludes the interview. Would you like feedback?")
            return
        }

        let question = questions[currentQuestionIndex]
        askQuestion(question: question)
    }
    
    override func processSpeechTask(audioData: Data) -> Task<Void, Never> {
        Task { [unowned self] in
            do {
                await MainActor.run {
                    self.state = .processing
                }

                let userResponse = try await client.generateAudioTransciptions(audioData: audioData)
                await addSpeechToConvo("user: ", userResponse)
                try Task.checkCancellation()

                let isLastQuestion = await currentQuestionIndex == questions.count - 1

                let feedbackPrompt = isLastQuestion
                ? """
                The user answered an interview question with: "\(userResponse) about the role". \
                Provide a short, professional closing remark to the interviewee. \
                Mention strengths from the interview and conclude with: \
                'We will closely look over your application and be back with you within the next few days.'
                """
                : """
                The user answered an interview question with: "\(userResponse) about the role". \
                Provide a short, constructive response that aligns with the specified job role '\(await role)'. \
                Also keep in mind the following key words: \(await keyWords.joined(separator: ", ")). \
                Then, smoothly transition to the next question.
                """

                let feedback = try await client.promptChatGPT(prompt: feedbackPrompt)

                await addSpeechToConvo("interviewer: ", feedback)

                let speechData = try await client.generateSpeechFrom(
                    input: feedback,
                    voice: .init(rawValue: newSelectedVoice.rawValue) ?? .alloy
                )

                try await MainActor.run {
                    try self.playAudio(data: speechData)
                    self.currentQuestionIndex += 1
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 13.0) {
                                Task { @MainActor in
                                    if self.currentQuestionIndex >= self.questions.count {
                                        self.isInterviewActive = false
                                        self.interviewComplete = true
                                        self.state = .finished // ✅ Now it's correctly placed after final answer
                                    } else if self.isInterviewActive {
                                        self.askNextInterviewQuestion()
                                    }
                                }
                            }

            } catch {
                if Task.isCancelled { return }
                await MainActor.run {
                    self.state = .error(error)
                    self.resetValues()
                }
            }
        }
    }
    
    
    @MainActor
    func playVoiceSample(for voice: VoiceType) async {
        do {
            let samplePrompt = "Hi there! I am youur Interview coach. Lets get started? "
            let data = try await client.generateSpeechFrom(
                input: samplePrompt,
                voice: .init(rawValue: voice.rawValue) ?? .alloy
                )
            try self.playAudio(data: data)
        } catch {
            print("Error playing sample voice: \(error)")
        }
    }
    
    func addSpeechToConvo(_ person: String, _ text: String) {
        print("adding \(text) from \(person)")
        self.currentConvo[person] = text
    }
    
    
    func performFeedback() async -> String {
        guard self.interviewComplete else { return "Interview Not Complete" }
        let formattedTranscript = currentConvo
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
        
        let prompt = """
        You're an experienced interview coach. Here's the conversation: 
        
        \(formattedTranscript)
        
        Give feedback on the candidate's responses. Mention strengths, weaknesses, \
            and how they can improve. 

        """

        print("fetching your feedback from Interviewer...")
        print("AI Feedback: \(self.interviewFeedBack)")
        do {
            self.interviewFeedBack = try await client.promptChatGPT(prompt: prompt)
            print("\(interviewFeedBack)")
            
        } catch {
            print("Error grabbing feedback: \(error)")
        }
        
        return self.interviewFeedBack
    }
     
    func uploadSessionToFirestore(uid: String) async {
        guard interviewComplete else { return }

        let db = Firestore.firestore()
        let docID = UUID().uuidString

        let formattedConvo = currentConvo
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")

        let sessionData: [String: Any] = [
            "role": self.role,
            "keywords": self.keyWords,
            "feedback": self.interviewFeedBack,
            "conversation": formattedConvo,
            "timestamp": Timestamp(date: Date())
        ]

        do {
            try await db.collection("users")
                .document(uid)
                .collection("interview_sessions")
                .document(docID)
                .setData(sessionData)

            print("✅ Interview session uploaded.")
        } catch {
            print("❌ Failed to upload session: \(error.localizedDescription)")
        }
    }
    
    override func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            if self.interviewComplete {
                print("✅ Finished interview playback. Keeping state as .finished.")
                return
            }

            // Safe to call from here since it's inside MainActor
            self.resetValues()
            self.state = .idle
        }
    } 
}

