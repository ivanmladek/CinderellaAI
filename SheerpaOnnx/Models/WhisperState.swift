import Foundation
import AVFoundation
import Combine

@MainActor
class WhisperState: NSObject, ObservableObject {
    @Published var isModelLoaded = false
    @Published var messageLog = ""
    @Published var canTranscribe = false
    @Published var isRecording = false
    @Published var transcribedText: String?
    @Published var isConversationInProgress = false

    private var whisperContext: WhisperContext?
    private var audioEngine: AVAudioEngine?
    private var audioInputNode: AVAudioInputNode?
    private var audioConverter: AVAudioConverter?
    private var accumulatedBuffer: AVAudioPCMBuffer?
    private var conversationHistory: [String] = []

    override init() {
        super.init()
        do {
            try loadModel()
            canTranscribe = true
        } catch {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.messageLog += "\(error.localizedDescription)\n"
            }
        }
    }

    private func loadModel() throws {
        DispatchQueue.main.async {
            self.messageLog += "Loading model...\n"
        }
        guard let modelUrl = Bundle.main.url(forResource: "ggml-base.en-q5_1", withExtension: "bin") else {
            DispatchQueue.main.async {
                self.messageLog += "Could not locate model file in the app bundle.\n"
            }
            throw NSError(domain: "WhisperState", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file not found"])
        }
        
        do {
            whisperContext = try WhisperContext.createContext(path: modelUrl.path)
            DispatchQueue.main.async {
                self.messageLog += "Loaded model \(modelUrl.lastPathComponent)\n"
            }
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.messageLog += "Failed to create Whisper context: \(error.localizedDescription)\n"
            }
            throw error
        } catch {
            DispatchQueue.main.async {
                self.messageLog += "An unexpected error occurred while loading the model: \(error.localizedDescription)\n"
            }
            throw error
        }
    }

    func startRecording() async {
        await requestRecordPermission { granted in
            if granted {
                Task {
                    do {
                        try self.beginRecording()
                    } catch {
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            self.messageLog += "\(error.localizedDescription)\n"
                            self.isRecording = false
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.messageLog += "Record permission not granted.\n"
                }
            }
        }
    }

    private func beginRecording() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        audioEngine = AVAudioEngine()
        audioInputNode = audioEngine?.inputNode

        guard let inputFormat = audioInputNode?.inputFormat(forBus: 0) else {
            throw NSError(domain: "WhisperState", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get input format"])
        }

        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false)
        audioConverter = AVAudioConverter(from: inputFormat, to: outputFormat!)

        let bufferSize: AVAudioFrameCount = 1024
        accumulatedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat!, frameCapacity: 16000 * 10)! // Buffer to accumulate 10 seconds of audio

        guard accumulatedBuffer != nil else {
            throw NSError(domain: "WhisperState", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PCM buffer"])
        }

        audioInputNode?.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] (buffer, time) in
            guard let self = self else { return }
            let inputBlock: AVAudioConverterInputBlock = { _, status in
                status.pointee = .haveData
                return buffer
            }
            var error: NSError?
            let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat!, frameCapacity: bufferSize)
            self.audioConverter?.convert(to: convertedBuffer!, error: &error, withInputFrom: inputBlock)
            if let convertedBuffer = convertedBuffer, error == nil {
                self.appendBuffer(convertedBuffer)
            }
        }

        try audioEngine?.start()
        isRecording = true
        DispatchQueue.main.async {
            self.messageLog += "Recording started...\n"
        }
    }

    private func appendBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let accumulatedBuffer else { return }

        let availableFrames = accumulatedBuffer.frameCapacity - accumulatedBuffer.frameLength
        let framesToCopy = min(buffer.frameLength, availableFrames)
        guard framesToCopy > 0 else { return }

        let sourcePointer = buffer.floatChannelData![0]
        let destinationPointer = accumulatedBuffer.floatChannelData![0].advanced(by: Int(accumulatedBuffer.frameLength))

        memcpy(destinationPointer, sourcePointer, Int(framesToCopy) * MemoryLayout<Float>.size)
        accumulatedBuffer.frameLength += framesToCopy
    }

    func stopRecording() async {
        audioEngine?.stop()
        audioInputNode?.removeTap(onBus: 0)
        isRecording = false
        if let buffer = accumulatedBuffer {
            await transcribeAudio(buffer)
        }
    }

    private func requestRecordPermission(response: @escaping (Bool) -> Void) async {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            response(granted)
        }
    }

    private func transcribeAudio(_ buffer: AVAudioPCMBuffer) async {
        if (!canTranscribe) {
            return
        }
        guard let whisperContext else {
            return
        }

        canTranscribe = false
        DispatchQueue.main.async {
            self.messageLog += "Transcribing data...\n"
        }
        let data = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
        print("Transcribing data with length: \(data.count)")
        await whisperContext.fullTranscribe(samples: data)
        let text = await whisperContext.getTranscription()
        DispatchQueue.main.async {
            self.messageLog += "Done: \(text)\n"
            self.transcribedText = text
            self.conversationHistory.append("User: \(text)")
        }

        canTranscribe = true
    }
}
