import SwiftUI

struct StoryView: View {
    @StateObject private var whisperState = WhisperState()
    @StateObject private var openAIManager = OpenAIManager()
    @StateObject private var elevenLabsManager = ElevenLabsManager()
    @State private var currentIcon: Icon = .ear // Default to ear icon
    @State private var isProcessing = false

    let story: Story
  
    enum Icon {
        case ear
        case mouth
        case brain
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    Text(whisperState.messageLog)
                        .padding()
                        .id(whisperState.messageLog)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: whisperState.messageLog) { _ in
                    withAnimation {
                        scrollView.scrollTo(whisperState.messageLog, anchor: .bottom)
                    }
                }
            }

            if currentIcon == .ear {
                Image(systemName: "ear.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
            } else if currentIcon == .mouth {
                Image(systemName: "mouth.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.red)
            } else if currentIcon == .brain {
                Image(systemName: "brain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
            }
        }
        .onAppear {
            startSession()
        }
        .onChange(of: whisperState.isRecording) { newValue in
            currentIcon = newValue ? .mouth : .ear
        }
    }

    private func startSession() {
        whisperState.messageLog = "Welcome to \(story.title) AI. Listen to the story and answer the questions. "
        Task {
            await elevenLabsManager.speakText("Welcome to \(story.title) AI. Listen to the story and answer the questions. ")
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
        let paragraphs = story.text.split(separator: ".")
        var paragraphCount = 0

        for paragraph in paragraphs {
            // Speak the paragraph
            currentIcon = .mouth
            await elevenLabsManager.speakText(String(paragraph))
            whisperState.messageLog += "\nAssistant: \(paragraph)"

            // Wait until speaking is done
            await waitForSpeakingToFinish(timeout: 10.0)

            paragraphCount += 1

            if paragraphCount % 10 == 0 {
                // Ask a question about the paragraph
                let question = await story.generateQuestion(for: String(paragraph))
                await elevenLabsManager.speakText(question)
                whisperState.messageLog += "\nAssistant: \(question)"

                // Wait until speaking is done
                await waitForSpeakingToFinish(timeout: 10.0)

                // Listen for the child's answer
                await listenForAnswer()

                // Provide feedback on the child's answer
                let feedback = await story.provideFeedback(for: whisperState.transcribedText ?? "")
                whisperState.messageLog += "\nAssistant: \(feedback)"
                await elevenLabsManager.speakText(feedback)

                // Wait until speaking is done
                await waitForSpeakingToFinish(timeout: 10.0)
            }
        }
    }

    private func listenForAnswer() async {
        guard !isProcessing else {
            return
        }
        guard !elevenLabsManager.isSpeaking else {
            return
        }
        isProcessing = true

        do {
            currentIcon = .ear
            if !whisperState.isRecording {
                await whisperState.startRecording()
                try await Task.sleep(nanoseconds: 10_000_000_000) // Simulate 10 seconds of recording
                await whisperState.stopRecording()
            }

            currentIcon = .brain
            while whisperState.transcribedText == nil {
                try await Task.sleep(nanoseconds: 100_000_000) // Sleep for 100 milliseconds
            }

            guard let transcribedText = whisperState.transcribedText else {
                whisperState.messageLog += "\nNo transcription available."
                isProcessing = false
                return
            }

            whisperState.messageLog += "\nChild: \(transcribedText)"

            isProcessing = false
        } catch {
            isProcessing = false
            // Handle the error as needed
        }
    }
}
