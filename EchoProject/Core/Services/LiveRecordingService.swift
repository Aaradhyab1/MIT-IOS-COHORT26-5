import Foundation
import AVFoundation

/// Where recordings are kept: a private temporary folder on the iPhone.
/// Recordings never leave the device. Each new recording replaces the old ones,
/// and the system clears the folder on its own.
enum RecordingFiles {
    static var folder: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("EchoRecordings", isDirectory: true)
    }

    static func url(for fileName: String) -> URL {
        folder.appendingPathComponent(fileName)
    }

    static func deleteAll() {
        try? FileManager.default.removeItem(at: folder)
    }
}

/// Puts the shared audio session into play-and-record mode, so one screen can
/// speak to the child and then listen to them.
enum EchoAudioSession {
    /// Returns false (and prints why in the Xcode console) if iOS refused the setup.
    @discardableResult
    static func activate() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try session.setActive(true)
            return true
        } catch {
            print("[Echo audio] Could not set up the audio session: \(error)")
            return false
        }
    }
}

/// Records the child with the real microphone (AVAudioRecorder) and plays
/// the recording back (AVAudioPlayer).
///
/// While recording it samples the loudness ten times a second and keeps the
/// loudest value, so a ViewModel can tell "no voice" from "said something".
@MainActor
final class LiveRecordingService: RecordingService {
    private(set) var isRecording = false

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var meterTask: Task<Void, Never>?
    private var loudestLevel: Double = 0

    func requestPermission() async -> Bool {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            return true
        case .denied:
            return false
        default:
            return await AVAudioApplication.requestRecordPermission()
        }
    }

    func startRecording() {
        stopPlayback()
        isRecording = false
        guard EchoAudioSession.activate() else { return }

        // Keep only the newest attempt on the phone.
        RecordingFiles.deleteAll()
        do {
            try FileManager.default.createDirectory(at: RecordingFiles.folder, withIntermediateDirectories: true)
        } catch {
            print("[Echo recording] Could not create the recordings folder: \(error)")
            return
        }

        // 16 kHz mono is what speech recognition works best with, and keeps files small.
        let fileName = "attempt-\(UUID().uuidString).wav"
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16_000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]

        let newRecorder: AVAudioRecorder
        do {
            newRecorder = try AVAudioRecorder(url: RecordingFiles.url(for: fileName), settings: settings)
        } catch {
            print("[Echo recording] Could not create the recorder: \(error)")
            return
        }
        newRecorder.isMeteringEnabled = true
        newRecorder.prepareToRecord()
        guard newRecorder.record() else {
            print("[Echo recording] The microphone did not start (record() returned false).")
            return
        }

        recorder = newRecorder
        loudestLevel = 0
        isRecording = true
        startMetering()
    }

    func stopRecording() -> RecordingResult {
        meterTask?.cancel()
        meterTask = nil
        isRecording = false

        guard let recorder else {
            return RecordingResult(fileName: nil, duration: 0, peakLevel: 0)
        }
        sampleLevel()
        let duration = recorder.currentTime     // read before stop(), which resets it
        recorder.stop()
        self.recorder = nil
        print("[Echo recording] Recorded \(String(format: "%.1f", duration)) s, loudest level \(String(format: "%.3f", loudestLevel)).")

        return RecordingResult(
            fileName: recorder.url.lastPathComponent,
            duration: duration,
            peakLevel: loudestLevel
        )
    }

    func playRecording(_ result: RecordingResult) async {
        guard let fileName = result.fileName,
              let newPlayer = try? AVAudioPlayer(contentsOf: RecordingFiles.url(for: fileName)) else {
            return
        }
        stopPlayback()
        EchoAudioSession.activate()
        player = newPlayer
        newPlayer.play()
        while newPlayer.isPlaying && !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(100))
        }
        if player === newPlayer {
            player = nil
        }
    }

    // MARK: - Private

    private func stopPlayback() {
        player?.stop()
        player = nil
    }

    private func startMetering() {
        meterTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.sampleLevel()
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    private func sampleLevel() {
        guard let recorder else { return }
        recorder.updateMeters()
        let decibels = Double(recorder.peakPower(forChannel: 0))   // -160 (silence) ... 0 (loudest)
        let level = pow(10, decibels / 20)                          // the same loudness on a 0 ... 1 scale
        loudestLevel = max(loudestLevel, level)
    }
}
