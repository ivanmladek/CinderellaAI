import Foundation
import CryptoKit
import Network
import UIKit // Add this import
import CommonCrypto

class StoryHelper: ObservableObject {
    private let elevenLabsManager: ElevenLabsManager
    private let whisperState: WhisperState
    private var story: String
    private var isProcessing = false // Add this property
    
    init(elevenLabsManager: ElevenLabsManager, whisperState: WhisperState, story: String) {
        self.elevenLabsManager = elevenLabsManager
        self.whisperState = whisperState
        self.story = story
    }
    
    func startSession(with story: String) {
        self.story = story
        Task {
            await MainActor.run {
                whisperState.messageLog = "Welcome to the story session. Listen to the story and answer the questions. "
            }
            await elevenLabsManager.speakText("Welcome to the story session. Listen to the story and answer the questions. ")
            await readStory()
        }
    }
    
    private func waitForSpeakingToFinish(timeout: TimeInterval) async {
        let startTime = Date()
        while elevenLabsManager.isSpeaking {
            let elapsedTime = Date().timeIntervalSince(startTime)
            if elapsedTime >= timeout {
                break
            }
            let remainingTime = timeout - elapsedTime
            try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
        }
    }
    
    private func readStory() async {
        // Keep the screen awake
        await MainActor.run {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        let paragraphs = story.split(separator: ".")
        var paragraphCount = 0
        
        for paragraph in paragraphs {
            // Speak the paragraph
            await elevenLabsManager.speakText(String(paragraph))
            await MainActor.run {
                whisperState.messageLog += "\nAssistant: \(paragraph)"
            }
            
            // Wait until speaking is done
            await waitForSpeakingToFinish(timeout: 10.0)
            
            paragraphCount += 1
            
        }
        
        // Re-enable the idle timer
        await MainActor.run {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func generateQuestion(for paragraph: String) async -> String {
        let questionPrompt = "You are Socrates, an AI TUTOR helping a child understand and reflect on any fairy tale they are reading or listening to. The child has mentioned \"\(paragraph)\" in relation to the fairy tale. Your task is to create a prompt that encourages the child to reflect on the events and characters in the tale. Ask questions that help the child recall specific details from the story, understand the actions and motivations of the characters, and discuss the outcomes of their actions. Use simple, engaging language and make sure the questions are age-appropriate. Remember, your response should be in English and suitable for a 2-7 year old. ASK A SINGLE EASY QUESTION."
        return questionPrompt
    }
    
    private func listenForAnswer() async {
        print("listenForAnswer: Checking isProcessing flag. Current value: \(isProcessing)")
        print("listenForAnswer: Checking listening flag. Current value: \(elevenLabsManager.isSpeaking)")
        
        guard !isProcessing else {
            print("listenForAnswer: Already processing, returning.")
            return
        }
        guard !elevenLabsManager.isSpeaking else {
            print("listenForAnswer: Still talking, returning.")
            return
        }
        isProcessing = true
        print("listenForAnswer: Started processing.")
        
        do {
            if await !whisperState.isRecording {
                print("listenForAnswer: Starting recording.")
                await whisperState.startRecording() // Add await here
                try await Task.sleep(nanoseconds: 10_000_000_000) // Simulate 10 seconds of recording
                await whisperState.stopRecording() // Add await here
                print("listenForAnswer: Stopped recording.")
            }
            
            while await whisperState.transcribedText == nil {
                print("listenForAnswer: Waiting for transcription to be available.")
                try await Task.sleep(nanoseconds: 100_000_000) // Sleep for 100 milliseconds
            }
            
            guard let transcribedText = await whisperState.transcribedText else {
                await MainActor.run {
                    whisperState.messageLog += "\nNo transcription available."
                }
                print("listenForAnswer: No transcription available.")
                isProcessing = false
                return
            }
            
            await MainActor.run {
                whisperState.messageLog += "\nChild: \(transcribedText)"
            }
            print("listenForAnswer: Received transcription: \(transcribedText)")
            
            isProcessing = false
            print("listenForAnswer: Finished processing. isProcessing flag reset to \(isProcessing)")
        } catch {
            print("listenForAnswer: Error occurred: \(error)")
            isProcessing = false
            // Handle the error as needed
        }
    }
    
    private func provideFeedback(for answer: String) async -> String {
        let feedbackPrompt = "You are Socrates, an AI TUTOR helping a child understand and reflect on any fairy tale they are reading or listening to. The child has given the following answer to a question about the fairy tale: \"\(answer)\". Your task is to provide positive and constructive feedback that encourages the child to think more deeply about the story. Use simple, engaging language and make sure the feedback is age-appropriate. Remember, your response should be in English and suitable for a 2-7 year old."
        return feedbackPrompt
    }
    
    
    
}
