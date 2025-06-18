import Foundation
import Network

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

class OpenAIManager: ObservableObject {
    private var aiModel: Phi3ViewModel?

    init() {
        self.aiModel = Phi3ViewModel()
    }

    func fetchResponse(prompt: String) async -> String {
        await aiModel?.loadModel()
        if let aiModel = self.aiModel {
            return await aiModel.fetchAIResponse(prompt: prompt)
        } else {
            print("AI model is not available. Please try again later.")
            return "Let's continue with the story."
        }
    }
    
    func sendTextToAI(_ text: String) async -> String {
        return await fetchResponse(prompt: text)
    }
}
