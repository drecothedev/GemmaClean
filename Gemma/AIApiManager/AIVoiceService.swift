//
//  AIVoiceService.swift
//  Gemma
//
//  Created by Andre jones on 4/4/25.
//


import AVFoundation
import Foundation
import Observation
import XCAOpenAIClient

enum VoiceType: String, Codable, Hashable, Sendable, CaseIterable {
    case alloy
    case echo
    case fable
    case onyx
    case nova
    case shimmer
}

enum VoiceChatState {
    case idle
    case recording
    case playing
    case processing
    case finished
    case error(Error)
}

@Observable
class AIVoiceService: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate  {
    let client = OpenAIClient(apiKey: "yourKeyHere")
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    var recordingSession = AVAudioSession.sharedInstance()
    var animationTimer: Timer?
    var recordingTimer: Timer?
    var prevAudioPower: Double?
    var audioPower = 0.0 // Power of Siri wave form view
    var selectedVoice = VoiceType.alloy
    var processingSpeechTask: Task<Void, Never>?
    
    
    var captureUrl: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("Recording.m4a")
    }
    
    
    
    var state = VoiceChatState.idle {
        didSet { print(state)}
    }
    var isIdle: Bool {
        if case .idle = state {
            return true
        } else {
            return false
        }
    }
    
    
    var siriWaveFormOpacity: CGFloat {
        switch state {
        case .recording, .playing: return 1.0
        default: return 0.0
        }
    }
    
    override init() {
        super.init()
        do {
            try recordingSession.setCategory(.playAndRecord, options: .defaultToSpeaker) // Sets rules for recording session
            try recordingSession.setActive(true)
            
            AVAudioApplication.requestRecordPermission { [unowned self] allowed in
                if !allowed {
                    self.state = .error("User did not permit recording")
                }
                
            }
        } catch {
            state = .error(error)
        }
    }
    
    func startCapture() {
        resetValues()
        state = .recording
        do {
            audioRecorder = try AVAudioRecorder(url: captureUrl,
                                                settings: [
                                                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                                    AVSampleRateKey: 12000,
                                                    AVNumberOfChannelsKey: 1,
                                                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                                                ])
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.record()
            
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self] _ in
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1,max(0, 1 - abs(Double(audioRecorder.averagePower(forChannel: 0)) / 50)))
                self.audioPower = power
            })
            var silenceDuration: TimeInterval = 0
            let silenceThreshold: Double = 0.5
            let maxSilentTime: TimeInterval = 2.0
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [unowned self ] _ in
                guard let recorder = self.audioRecorder else { return }
                
                recorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(recorder.averagePower(forChannel: 0)) / 50)))
                
                self.audioPower = power
                
                if power < silenceThreshold {
                    silenceDuration += 0.2
                } else {
                    silenceDuration = 0
                }
                
                if silenceDuration >= maxSilentTime {
                    self.finsihCaptureAudio()
                }
            }
            
        } catch {
            resetValues()
            state = .error(error)
        }
    }
                                                  
    func finsihCaptureAudio() {
        resetValues()
        do {
            let data = try Data(contentsOf: captureUrl)
            processingSpeechTask = processSpeechTask(audioData: data)
        } catch {
            state = .error(error)
            resetValues()
        }
    }
    
    
    
    func processSpeechTask(audioData: Data) -> Task<Void, Never> {
        Task { @MainActor [unowned self] in
            do {
                self.state = .processing
                let prompt = try await client.generateAudioTransciptions(audioData: audioData)
                
                try Task.checkCancellation()
                let responseText = try await client.promptChatGPT(prompt: prompt)
                
                try Task.checkCancellation()
                let data = try await client.generateSpeechFrom(input: responseText, voice: .init(rawValue: selectedVoice.rawValue) ?? .alloy)
                
                try Task.checkCancellation()
                try self.playAudio(data: data)
            } catch {
                if Task.isCancelled { return }
                state = .error(error)
                resetValues()
            }
            
        }
    }
    
    func askQuestion(question: String) {
        Task { @MainActor [unowned self] in
            do {
                self.state = .processing
                let responseText = try await client.promptChatGPT(prompt: question)
                let data = try await client.generateSpeechFrom(input: responseText, voice: .init(rawValue: selectedVoice.rawValue) ?? .alloy)
                
                try self.playAudio(data: data)
                
            } catch {
                state = .error(error)
                resetValues()
            }
        }
    }
    
    func playAudio(data: Data) throws {
        self.state = .playing
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer.isMeteringEnabled = true
        audioPlayer.delegate = self
        audioPlayer.play()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self] _ in
            guard self.audioPlayer != nil else { return }
            self.audioPlayer.updateMeters()
            let power = min(1,max(0, 1 - abs(Double(audioPlayer.averagePower(forChannel: 0)) / 160)))
            self.audioPower = power
        })
    }
    
    func cancelRecording() {
        resetValues()
        state = .idle
    }
    
    
    func cancelProcessingTask() {
        processingSpeechTask?.cancel()
        processingSpeechTask = nil
        resetValues()
        state = .idle
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            resetValues()
            state = .idle
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        resetValues()
        state = .idle
    }
    
    
    func resetValues() {
        audioPower = 0
        prevAudioPower = nil
        audioRecorder?.stop()
        audioRecorder = nil
        audioPlayer?.stop()
        audioPlayer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    
    
    
}

