import Foundation
import Network
import CryptoKit
import strathweb_phi_engineFFI

enum MessageState {
    case ok
    case waiting
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let state: MessageState
}

class Phi3ViewModel: NSObject, ObservableObject, URLSessionDownloadDelegate {
    var engine: StatefulPhiEngine?
    let inferenceOptions: InferenceOptions
    @Published var isLoading: Bool = false
    @Published var isLoadingEngine: Bool = false
    @Published var messages: [ChatMessage] = []
    @Published var prompt: String = ""
    @Published var isReady: Bool = false
    @Published var showWifiMessage: Bool = false
    @Published var downloadProgress: Double = 0.0
    
    private var pathMonitor: NWPathMonitor?
    private var isWifiConnected: Bool = false
    private var downloadTask: URLSessionDownloadTask?
    private var urlSession: URLSession?
    
    override init() {
        let inferenceOptionsBuilder = InferenceOptionsBuilder()
        try! inferenceOptionsBuilder.withTemperature(temperature: 0.9)
        try! inferenceOptionsBuilder.withSeed(seed: 146628346)
        try! inferenceOptionsBuilder.withTokenCount(contextWindow: 500) // Reduced for mobile safety
        self.inferenceOptions = try! inferenceOptionsBuilder.build()
        
        super.init()
        setupNetworkMonitor()
        setupURLSession()
    }
    
    deinit {
        pathMonitor?.cancel()
    }
    
    private func setupNetworkMonitor() {
        pathMonitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isWifiConnected = path.usesInterfaceType(.wifi)
            if !self.isWifiConnected && self.isLoadingEngine {
                self.cancelModelDownload()
            }
        }
        pathMonitor?.start(queue: queue)
    }
    
    private func setupURLSession() {
        let config = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    private func cancelModelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        DispatchQueue.main.async {
            self.isLoadingEngine = false
        }
    }
    
    func loadModel() async {
        guard isWifiConnected else {
            DispatchQueue.main.async {
                self.showWifiMessage = true
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoadingEngine = true
        }
        
        let model_repo = "bartowski/Phi-3-mini-4k-instruct-v0.3-GGUF"
        let model_filename = "Phi-3-mini-4k-instruct-v0.3-Q3_K_L.gguf"
        let modelRevision = "main"
        let directoryName = "models--" + model_repo.replacingOccurrences(of: "/", with: "--") + "/blobs/"
        let modelProvider = PhiModelProvider.huggingFace(
            modelRepo: model_repo,
            modelFileName: model_filename,
            modelRevision: modelRevision
        )
        
        let engineBuilder = PhiEngineBuilder()
        try! engineBuilder.withModelProvider(modelProvider: modelProvider)
        try! engineBuilder.tryUseGpu()
        try! engineBuilder.withEventHandler(eventHandler: BoxedPhiEventHandler(handler: ModelEventsHandler(parent: self)))
        
        let modelDirectory = FileManager.default.temporaryDirectory.path + "/" + directoryName
        
        let systemInstruction2 = 
        """
        Write a classic fairytale in three acts:
        Act 1: Introduce a main character, setting, and hint at a good vs. evil conflict.
        Act 2: The character faces a quest or problem with magical elements, helpers, and villains, making moral choices.
        Act 3: The character overcomes evil, restores harmony, and ends with a clear moral lesson.
        Story should be suitable for children and highlight hope, bravery, or kindness.
        DO NOT SOUND FAKE AND GAY AND NO SEXUAL CONTENT AND AFFIRMATIVE SHIT OR "COMMUNITY". 
        
        """
        
        self.engine = try! engineBuilder.buildStateful(
            cacheDir: modelDirectory,
            systemInstruction: systemInstruction2
        )
        
        DispatchQueue.main.async {
            self.isLoadingEngine = false
            self.isReady = true
        }
    }
    
    func fetchAIResponse() async {
        if let engine = self.engine {
            let question = self.prompt
            DispatchQueue.main.async {
                self.isLoading = true
                self.prompt = ""
                self.messages.append(ChatMessage(text: question, isUser: true, state: .ok))
                self.messages.append(ChatMessage(text: "", isUser: false, state: .waiting))
            }
            
            let inferenceResult = try! engine.runInference(promptText: question, inferenceOptions: self.inferenceOptions)
            print("\nTokens Generated: \(inferenceResult.tokenCount), Tokens per second: \(inferenceResult.tokensPerSecond), Duration: \(inferenceResult.duration)s")
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    class ModelEventsHandler: PhiEventHandler {
        unowned let parent: Phi3ViewModel
        
        init(parent: Phi3ViewModel) {
            self.parent = parent
        }
        
        func onInferenceToken(token: String) throws {
            DispatchQueue.main.async {
                if let lastMessage = self.parent.messages.last {
                    let updatedText = lastMessage.text + token
                    if let index = self.parent.messages.firstIndex(where: { $0.id == lastMessage.id }) {
                        self.parent.messages[index] = ChatMessage(text: updatedText, isUser: false, state: .ok)
                    }
                }
                print(token) // Print the token as it is generated
            }
        }
        
        func onModelLoaded() throws {
            print("MODEL LOADED")
        }
        
        func onInferenceStarted() throws {
            print("INFERENCE STARTED")
        }
        
        func onInferenceEnded() throws {
            print("INFERENCE ENDED")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.downloadProgress = progress
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Handle the downloaded file
    }
    
    func truncateToMaxTokens(_ text: String, maxTokens: Int = 512) -> String {
        let tokens = text.split(separator: " ")
        if tokens.count > maxTokens {
            return tokens.prefix(maxTokens).joined(separator: " ")
        } else {
            return text
        }
    }
}
