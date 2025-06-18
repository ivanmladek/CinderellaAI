import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = Phi3ViewModel()
    @StateObject private var elevenLabsManager = ElevenLabsManager()
    @State private var selectedStory: Story? = nil
    @State private var isSubmenuActive = false
    @State private var showWifiMessage = false
    @State private var generatingStory = false
    @State private var stories: [Story] = []
    @State private var isModelDownloading = false
    @State private var isModelReady = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        Spacer()
                        List(stories.indices, id: \.self) { index in
                            Button(action: {
                                selectedStory = stories[index]
                                isSubmenuActive = true
                            }) {
                                Text(stories[index].title)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                            }
                        }
                        .sheet(isPresented: $isSubmenuActive) {
                            if let story = selectedStory {
                                StorySubmenuView(story: story.content, elevenLabsManager: elevenLabsManager)
                            } else {
                                LoadModelSubmenuView(viewModel: viewModel, stories: $stories, generatingStory: $generatingStory, isSubmenuActive: $isSubmenuActive, isModelDownloading: $isModelDownloading, isModelReady: $isModelReady)
                            }
                        }

                        Button(action: {
                            if !generatingStory && isModelReady {
                                isSubmenuActive = true
                                selectedStory = nil
                            } else if !isModelReady {
                                // Model is not ready, show download progress
                                isSubmenuActive = true
                            }
                        }) {
                            if generatingStory {
                                HStack {
                                    Text("New Story")
                                    ProgressView()
                                }
                                .padding(10)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            } else if isModelDownloading {
                                HStack {
                                    Text("Downloading Model...")
                                    ProgressView()
                                }
                                .padding(10)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            } else {
                                Text("New Story")
                                    .padding(10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                            }
                        }
                        .disabled(generatingStory || isModelDownloading)
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.white)
                }
                .edgesIgnoringSafeArea(.all)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .navigationTitle("Phi-3 Assistant")
        .onAppear {
            loadStoriesFromFile()
            startModelDownload()
        }
    }

    private func loadStoriesFromFile() {
        let fileName = "stories.json"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            do {
                let data = try Data(contentsOf: fileURL)
                let loadedStories = try JSONDecoder().decode([Story].self, from: data)
                
                // Check if default stories already exist in loaded stories
                let defaultTitles = ["Cinderella", "Snow White", "Rapunzel", "Sleeping Beauty"]
                let existingTitles = loadedStories.map { $0.title }
                
                var storiesToAdd: [Story] = []
                
                // Only add default stories that don't already exist
                if !existingTitles.contains("Cinderella") {
                    storiesToAdd.append(Story(title: "Cinderella", content: cinderellaStory, index: 0))
                }
                if !existingTitles.contains("Snow White") {
                    storiesToAdd.append(Story(title: "Snow White", content: snowWhiteStory, index: 1))
                }
                if !existingTitles.contains("Rapunzel") {
                    storiesToAdd.append(Story(title: "Rapunzel", content: rapunzelStory, index: 2))
                }
                if !existingTitles.contains("Sleeping Beauty") {
                    storiesToAdd.append(Story(title: "Sleeping Beauty", content: sleepingBeautyStory, index: 3))
                }
                
                stories = loadedStories + storiesToAdd
            } catch {
                print("Error reading stories: \(error). Using default stories.")
                stories = [
                    Story(title: "Cinderella", content: cinderellaStory, index: 0),
                    Story(title: "Snow White", content: snowWhiteStory, index: 1),
                    Story(title: "Rapunzel", content: rapunzelStory, index: 2),
                    Story(title: "Sleeping Beauty", content: sleepingBeautyStory, index: 3)
                ]
            }
        }
    }

    private func startModelDownload() {
        Task {
            isModelDownloading = true
            do {
                try await viewModel.loadModel()
                isModelReady = true
                isModelDownloading = false
            } catch {
                print("Model download failed: \(error)")
                isModelDownloading = false
                // Handle error, e.g., show alert to user
            }
        }
    }
}

struct LoadModelSubmenuView: View {
    @ObservedObject var viewModel: Phi3ViewModel
    @Binding var stories: [Story]
    @Binding var generatingStory: Bool
    @Binding var isSubmenuActive: Bool
    @Binding var isModelDownloading: Bool
    @Binding var isModelReady: Bool

    @StateObject private var whisperState = WhisperState()

    @State private var promptText = "Make new story about...?"

    var body: some View {
        if isModelDownloading {
            VStack {
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle())
                Text("Downloading model... Please wait.")
                Button("Back to Menu") {
                    isSubmenuActive = false
                }
            }
            .padding()
        } else if !isModelReady {
            VStack {
                Button("Download Model") {
                    Task {
                        isModelDownloading = true
                        do {
                            try await viewModel.loadModel()
                            isModelReady = true
                            isModelDownloading = false
                        } catch {
                            print("Model download failed: \(error)")
                            isModelDownloading = false
                            // Handle error
                        }
                    }
                }
                .padding()
            }
        } else {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                MessageView(message: message).padding(.bottom)
                            }
                        }
                        .id("wrapper").padding()
                        .padding()
                    }
                    .onChange(of: viewModel.messages.last?.id, perform: { value in
                        if viewModel.isLoading {
                            proxy.scrollTo("wrapper", anchor: .bottom)
                        } else if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    })
                }

                HStack {
                    TextField(promptText, text: $viewModel.prompt, onCommit: {
                        generateStory()
                    })
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    Image(systemName: whisperState.isRecording ? "mic.fill" : "mic.slash.fill")
                        .font(.system(size: 24))
                        .foregroundColor(whisperState.isRecording ? .red : .blue)
                        .padding(.trailing)
                        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { isPressing in
                            if isPressing {
                                startRecording()
                            } else {
                                if whisperState.isRecording {
                                    stopRecording()
                                }
                            }
                        }, perform: { })
                }
                .padding(.bottom)
            }
            .onChange(of: whisperState.transcribedText) { newText in
                if let newText = newText, !newText.isEmpty {
                    viewModel.prompt = newText
                    generateStory()
                }
            }
        }
    }

    private func startRecording() {
        print("Start recording...")
        Task {
            await whisperState.startRecording()
        }
    }

    private func stopRecording() {
        print("Stop recording...")
        Task {
            await whisperState.stopRecording()
        }
    }

    private func generateStory() {
        generatingStory = true
        Task {
            // Modify prompt to ask for title
            let userPrompt = viewModel.prompt
            viewModel.prompt = "Generate a short, creative title (5 words or less) on the very first line for a story about \"\(userPrompt)\". Then, after a newline, write the story itself."

            await viewModel.fetchAIResponse()

            // Extract title and content from response
            let fullResponse = viewModel.messages.last?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            var newStoryTitle = "New Story"
            var newStoryContent = fullResponse

            let lines = fullResponse.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
            
            if lines.count > 1 {
                newStoryTitle = String(lines[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                newStoryContent = String(lines[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else if !fullResponse.isEmpty {
                newStoryTitle = fullResponse.split(separator: "\n").first.map(String.init) ?? "New Story"
            }
            
            let newStory = Story(title: newStoryTitle, content: newStoryContent, index: stories.count)
            stories.append(newStory)
            saveStoriesToFile(stories)
            
            // Reset things and dismiss the view
            generatingStory = false
            viewModel.prompt = "" // Clear the prompt for the next use
            isSubmenuActive = false // Dismiss after completion
        }
    }

    private func saveStoriesToFile(_ stories: [Story]) {
        let fileName = "stories.json"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            do {
                // Filter out default stories before saving
                let defaultTitles = ["Cinderella", "Snow White", "Rapunzel", "Sleeping Beauty"]
                let userStories = stories.filter { !defaultTitles.contains($0.title) }
                
                let data = try JSONEncoder().encode(userStories)
                try data.write(to: fileURL)
            } catch {
                print("Error saving stories: \(error)")
            }
        }
    }
}

struct Story: Identifiable, Codable {
    let id = UUID()
    let title: String
    let content: String
    let index: Int
}

struct StorySubmenuView: View {
    let story: String
    @ObservedObject var elevenLabsManager: ElevenLabsManager
    @State private var sentences: [String] = []
    @State private var currentSentenceIndex = 0
    @State private var currentSentence: String = ""
    @State private var isPlayingContinuously = false
    @State private var shouldStopNarration = false

    var body: some View {
        VStack {
            Text(currentSentence)
                .padding()

            HStack {
                Button(action: {
                    if currentSentenceIndex > 0 {
                        currentSentenceIndex -= 1
                        Task {
                            await elevenLabsManager.speakText(currentSentence)
                        }
                        currentSentence = sentences[currentSentenceIndex]
                    }
                }) {
                    Image(systemName: "backward.end.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }

                Button(action: {
                    isPlayingContinuously.toggle()
                    if isPlayingContinuously {
                        shouldStopNarration = false
                        playStoryContinuously()
                    } else {
                        shouldStopNarration = true
                    }
                }) {
                    Image(systemName: isPlayingContinuously ? "stop.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }

                Button(action: {
                    if currentSentenceIndex < sentences.count - 1 {
                        currentSentenceIndex += 1
                        Task {
                            await elevenLabsManager.speakText(currentSentence)
                        }
                        currentSentence = sentences[currentSentenceIndex]
                    }
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            sentences = story.split(separator: ".").map { String($0).trimmingCharacters(in: .whitespaces) + "." }
            if let firstSentence = sentences.first {
                currentSentence = firstSentence
            }
        }
        .onDisappear {
            shouldStopNarration = true
        }
    }

    private func playStoryContinuously() {
        Task {
            while currentSentenceIndex < sentences.count && !shouldStopNarration {
                // Prepare the current sentence's audio if it's not already cached.
                // This also serves to pre-warm the audio for the very first sentence.
                await elevenLabsManager.prepareAudio(for: sentences[currentSentenceIndex])
                
                if shouldStopNarration { break }
                
                currentSentence = sentences[currentSentenceIndex]
                
                // Pre-generate audio for the next sentence in the background.
                let nextSentenceIndex = currentSentenceIndex + 1
                if nextSentenceIndex < sentences.count {
                    Task.detached {
                        await self.elevenLabsManager.prepareAudio(for: self.sentences[nextSentenceIndex])
                    }
                }
                
                // Start audio playback for the current sentence and wait for it to complete.
                await elevenLabsManager.speakText(currentSentence)
                
                // Wait for the current sentence to finish playing.
                while elevenLabsManager.isSpeaking {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                    if shouldStopNarration { break }
                }
                
                if shouldStopNarration { break }
                
                // Move to the next sentence.
                if currentSentenceIndex < sentences.count - 1 {
                    currentSentenceIndex += 1
                } else {
                    // This was the last sentence.
                    break
                }
            }
            // Ensure isPlayingContinuously is set to false when the loop finishes or is stopped.
            isPlayingContinuously = false
        }
    }
}

struct MessageView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                if message.state == .waiting {
                    TypingIndicatorView()
                } else {
                    VStack {
                        Text(message.text)
                            .padding()
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
}

struct TypingIndicatorView: View {
    @State private var shouldAnimate = false

    var body: some View {
        HStack {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.gray)
                    .offset(y: shouldAnimate ? -5 : 0)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(Double(index) * 0.2)
                    )
            }
        }
        .onAppear { shouldAnimate = true }
        .onDisappear { shouldAnimate = false }
    }
}

@main
struct Socrates4Kids: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
