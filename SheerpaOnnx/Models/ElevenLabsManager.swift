import Foundation
import AVFoundation
import CommonCrypto

class ElevenLabsManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isSpeaking = false

    private var tts: SherpaOnnxOfflineTtsWrapper
    private var audioPlayer: AVAudioPlayer?
    private var semaphore = DispatchSemaphore(value: 1)

    // Add a default initializer
    override init() {
        // Configuration for the TTS model
        let modelName = "model.onnx"
        let tokensName = "tokens.txt"
        let dataDirName = "espeak-ng-data"

        // Get the paths for the resources within the app bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: nil, subdirectory: "vits-coqui-en-ljspeech-neon") else {
            fatalError("Model file '\(modelName)' not found in the app bundle")
        }

        guard let tokensURL = Bundle.main.url(forResource: tokensName, withExtension: nil, subdirectory: "vits-coqui-en-ljspeech-neon") else {
            fatalError("Tokens file '\(tokensName)' not found in the app bundle")
        }

        guard let dataDirURL = Bundle.main.url(forResource: dataDirName, withExtension: nil, subdirectory: "vits-coqui-en-ljspeech-neon") else {
            fatalError("Data directory '\(dataDirName)' not found in the app bundle")
        }

        // Print the resolved paths
        print("Model Path: \(modelURL.path)")
        print("Tokens Path: \(tokensURL.path)")
        print("Data Dir Path: \(dataDirURL.path)")

        let vitsConfig = sherpaOnnxOfflineTtsVitsModelConfig(
            model: modelURL.path,
            lexicon: "", // Lexicon is not used as per the provided run() function
            tokens: tokensURL.path,
            dataDir: dataDirURL.path
        )
        let ttsModelConfig = sherpaOnnxOfflineTtsModelConfig(vits: vitsConfig)
        var ttsConfig = sherpaOnnxOfflineTtsConfig(model: ttsModelConfig)
        self.tts = SherpaOnnxOfflineTtsWrapper(config: &ttsConfig)

        super.init()
    }

    private func sha1(string: String) -> String {
        let data = string.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }

    private func getTempFilePath(for hash: String) -> URL {
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectoryURL.appendingPathComponent("\(hash).wav")
    }

    private func generateAndPlay(sentence: String, speakerId: Int, speed: Float, hash: String) async {
        let audio = tts.generate(text: sentence, sid: speakerId, speed: speed)
        let filename = getTempFilePath(for: hash)
        audio.save(filename: filename.path)

        playAudio(filename: filename)
    }

    private func playAudio(filename: URL) {
        semaphore.wait()
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: filename)
            self.audioPlayer?.delegate = self
            DispatchQueue.main.async {
                self.isSpeaking = true
            }
            self.audioPlayer?.play()
        } catch {
            print("Error playing audio file: \(error)")
            semaphore.signal()
        }
    }

    func prepareAudio(for text: String) async {
        let speakerId = 0
        let speed: Float = 0.9
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.isEmpty {
            return
        }

        let hash = sha1(string: trimmedText)
        let filename = getTempFilePath(for: hash)

        if !FileManager.default.fileExists(atPath: filename.path) {
            let audio = tts.generate(text: trimmedText, sid: speakerId, speed: speed)
            audio.save(filename: filename.path)
        }
    }

    func speakText(_ text: String) async {
        let speakerId = 0 // You can change this to the desired speaker ID
        let speed: Float = 0.9 // You can change this to the desired speed
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.isEmpty {
            print("Text is empty")
            return
        }

        let hash = sha1(string: trimmedText)
        let filename = getTempFilePath(for: hash)

        if FileManager.default.fileExists(atPath: filename.path) {
            // Play the existing file
            playAudio(filename: filename)
        } else {
            // Generate and play the audio
            await generateAndPlay(sentence: trimmedText, speakerId: speakerId, speed: speed, hash: hash)
        }
    }

    // Implement the AVAudioPlayerDelegate method to update isSpeaking property and signal the semaphore
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.semaphore.signal()
        }
    }
}
