![App Icon](https://raw.githubusercontent.com/ivanmladek/CinderellaAI/main/Assets.xcassets/AppIcon.appiconset/8-cMUROwLTm8kBW4E.png)

# CinderellaAI: AI Speech-to-Speech Storytelling App

CinderellaAI is a SwiftUI app that combines advanced voice-to-text transcription and AI-powered storytelling. It leverages state-of-the-art open source projects for speech recognition, text-to-speech, and large language model inference, all running locally on your device.

## Features

- **Voice-to-Text Transcription**: Convert spoken audio into text using cutting-edge models.
- **AI Storytelling**: Generate classic fairytales and stories with a local large language model.
- **Text-to-Speech**: Listen to generated stories or transcribed text with high-quality TTS.
- **Runs Locally**: All processing is done on-device for privacy and speed.

## Open Source Projects Used

This app integrates the following open source repositories:

- [strathweb-phi-engine](https://github.com/filipw/strathweb-phi-engine):
  - Provides local inference for Microsoft's Phi-3 language model, enabling on-device story generation and conversational AI.
- [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx):
  - Delivers fast, accurate speech-to-text (ASR) and text-to-speech (TTS) capabilities using ONNX models, supporting a wide range of platforms including iOS.
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp):
  - Implements OpenAI's Whisper speech recognition model in efficient C/C++ for real-time voice transcription on mobile and desktop.
- [coqui-ai/TTS](https://github.com/coqui-ai/TTS):
  - Offers high-quality neural text-to-speech synthesis, allowing the app to read stories and transcriptions aloud.

## Usage

1. Select or record an audio sample for transcription.
2. Use the AI to generate or continue a story based on your input.
3. Listen to the generated story or transcription using the built-in TTS.

## Setup

1. Download or build the required models for Whisper, SherpaOnnx, and Phi-3.
2. Add the models to the appropriate resource folders in Xcode.
3. Build and run the app on your iOS device (preferably with at least 6GB RAM for best performance).

## Repository Structure

### Key Swift Files in `SheerpaOnnx/Models`

- **CinderellaStory.swift**  
  Implements the `Story` protocol for the classic Cinderella fairytale. Contains the full story text and methods for generating questions and feedback related to the story, supporting interactive storytelling.

- **StoryView.swift**  
  SwiftUI view for displaying and interacting with stories, likely providing the user interface for story presentation and user input.

- **Phi3ViewModel.swift**  
  Manages the Phi-3 language model, including model loading, downloading, and inference. Handles AI-driven story generation and manages model events and download progress.

- **SherpaOnnx.swift**  
  Provides wrappers and configuration utilities for the Sherpa ONNX-based text-to-speech (TTS) engine. Manages TTS model setup and audio generation.

- **WhisperState.swift**  
  Manages the state and logic for speech-to-text transcription using the Whisper model. Handles audio recording, model loading, and transcription state.

- **ElevenLabsManager.swift**  
  Handles text-to-speech synthesis using the ElevenLabs API and the SherpaOnnx TTS wrapper. Manages audio playback and caching of generated speech.

- **Extension.swift**  
  Contains utility extensions for audio buffer manipulation, making it easier to convert audio buffers to arrays for processing.

- **OpenAIManager.swift**  
  Provides an interface for interacting with OpenAI models (via `Phi3ViewModel`). Handles sending prompts and receiving AI-generated responses for chat or story continuation.

- **SherpaOnnxViewModel.swift**  
  ViewModel for managing SherpaOnnx-related state, likely bridging between the UI and the ONNX-based models for transcription and TTS.

- **Model.swift**  
  Contains utility functions for loading and configuring various speech and language models, including resource management and model selection.

- **strathweb_phi_engine.swift**  
  Large file providing Swift bindings and utilities for the Strathweb Phi-3 engine, including inference options, result handling, and engine configuration.

- **SherpaOnnx-Bridging-Header.h**  
  Objective-C bridging header to expose C/C++ APIs (such as Sherpa ONNX) to Swift code.

## TODO

- ❌ Switch to Phi-4 in strathweb for improved story generation and conversational AI.
- ❌ Use whisper.cpp for Voice Activity Detection (VAD) to improve audio segmentation and responsiveness.
- ❌ Add voice cloning through coqui so kid stories can be narrated in the kid's own voice.

## Credits

This app would not be possible without the amazing work of the open source community:
- [strathweb-phi-engine](https://github.com/filipw/strathweb-phi-engine)
- [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx)
- [whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- [coqui-ai/TTS](https://github.com/coqui-ai/TTS)

---

For more details on each component, please refer to their respective repositories.
