import Foundation
import AVFoundation
import Accelerate

/// Checks the vowel in a recording by measuring its formants on the iPhone.
///
/// A vowel is shaped by the mouth, which boosts two bands of the voice: F1 (how open the
/// mouth is) and F2 (how far forward the tongue is). "aaa" has a high F1, "eee" a very
/// high F2, "ooo" a low F1 and F2. The service:
/// 1. reads the recording (AVFoundation),
/// 2. cuts it into 25 ms frames and keeps the voiced ones,
/// 3. estimates F1 and F2 in each frame with linear prediction (Accelerate),
/// 4. matches each frame to the nearest vowel on a chart of men's, women's and
///    children's voices (Hillenbrand et al., 1995),
/// 5. counts a try when the expected vowel family wins and lasts long enough.
///
/// Everything runs on the device; no audio leaves the phone.
@MainActor
final class LiveVowelCheckService: VowelCheckService {
    func check(_ recording: RecordingResult, expecting ipa: String) async -> VowelCheck {
        guard let fileName = recording.fileName else {
            return VowelCheck(isMatch: false, heard: nil, matchingSeconds: 0)
        }
        let url = RecordingFiles.url(for: fileName)
        let target = VowelFormants.family(of: ipa)
        let result = await Task.detached(priority: .userInitiated) {
            VowelAnalyzer.analyze(url: url, target: target)
        }.value
        print("[Echo vowel] expected \(target ?? "?"), heard \(result.heard ?? "nothing clear"), "
              + "\(String(format: "%.2f", result.matchingSeconds)) s matching → \(result.isMatch ? "counts" : "try again")")
        return result
    }
}

/// The formant chart and vowel families used by the check.
nonisolated enum VowelFormants {
    nonisolated struct Prototype {
        let vowel: String
        let f1: Double
        let f2: Double
    }

    /// Average F1/F2 (Hz) for men, women and children (Hillenbrand et al., 1995).
    static let chart: [Prototype] = {
        let rows: [(String, [(Double, Double)])] = [
            ("i", [(342, 2322), (437, 2761), (452, 3081)]),
            ("ɪ", [(427, 2034), (483, 2365), (511, 2552)]),
            ("e", [(476, 2089), (536, 2530), (564, 2656)]),
            ("ɛ", [(580, 1799), (731, 2058), (749, 2267)]),
            ("æ", [(588, 1952), (669, 2349), (717, 2501)]),
            ("ɑ", [(768, 1333), (936, 1551), (1002, 1688)]),
            ("ʌ", [(623, 1200), (753, 1426), (749, 1546)]),
            ("ɔ", [(652, 997), (781, 1136), (803, 1210)]),
            ("o", [(497, 910), (555, 1035), (597, 1137)]),
            ("ʊ", [(469, 1122), (519, 1225), (568, 1490)]),
            ("u", [(378, 997), (459, 1105), (494, 1345)]),
        ]
        return rows.flatMap { vowel, voices in voices.map { Prototype(vowel: vowel, f1: $0.0, f2: $0.1) } }
    }()

    /// Vowels close enough to count for each practised sound. Young children and
    /// hearing-aid users don't hit the exact vowel, so neighbours count; the other
    /// sounds' vowels never do (saying "eee" won't move Plane).
    static let families: [String: Set<String>] = [
        "ɑ": ["ɑ", "ʌ", "ɔ", "æ"],
        "u": ["u", "ʊ", "o"],
        "i": ["i", "ɪ", "e"],
    ]

    /// "ɑː" → "ɑ". Nil if the sound isn't one of the practised vowels.
    static func family(of ipa: String) -> String? {
        let base = ipa.replacingOccurrences(of: "ː", with: "")
        return families.keys.first { families[$0]?.contains(base) == true }
    }

    /// The nearest vowel on the chart, or nil when the frame is far from every vowel.
    static func nearestVowel(f1: Double, f2: Double, maxDistance: Double = 0.32) -> String? {
        var best: (vowel: String, distance: Double)?
        for p in chart {
            let d1 = log(f1 / p.f1), d2 = log(f2 / p.f2)
            let distance = (d1 * d1 + d2 * d2).squareRoot()
            if distance < (best?.distance ?? .infinity) { best = (p.vowel, distance) }
        }
        guard let best, best.distance <= maxDistance else { return nil }
        return best.vowel
    }

    /// Which practised family a vowel belongs to.
    static func familyOfVowel(_ vowel: String) -> String? {
        families.first { $0.value.contains(vowel) }?.key
    }
}

/// The signal processing, kept free of the main actor so it can run in the background.
nonisolated enum VowelAnalyzer {
    /// The expected vowel must last at least this long ...
    static let minimumMatchingSeconds = 0.25
    /// ... and make up at least this share of the frames that sounded like any vowel.
    static let minimumShare = 0.5

    static func analyze(url: URL, target: String?) -> VowelCheck {
        guard let target,
              let (samples, sampleRate) = readMono(url: url), sampleRate > 0 else {
            return VowelCheck(isMatch: false, heard: nil, matchingSeconds: 0)
        }
        let hop = Int(sampleRate * 0.010)
        let formants = formantTrack(samples, sampleRate: sampleRate)

        var familyFrames: [String: Int] = [:]
        var classified = 0
        for (f1, f2) in formants {
            guard let vowel = VowelFormants.nearestVowel(f1: f1, f2: f2) else { continue }
            classified += 1
            if let family = VowelFormants.familyOfVowel(vowel) {
                familyFrames[family, default: 0] += 1
            }
        }
        let matching = familyFrames[target] ?? 0
        let matchingSeconds = Double(matching * hop) / sampleRate
        let heard = familyFrames.max { $0.value < $1.value }?.key
        let isMatch = classified > 0
            && matchingSeconds >= minimumMatchingSeconds
            && Double(matching) >= minimumShare * Double(classified)
        return VowelCheck(isMatch: isMatch, heard: heard, matchingSeconds: matchingSeconds)
    }

    // MARK: - Reading the file

    static func readMono(url: URL) -> ([Float], Double)? {
        guard let file = try? AVAudioFile(forReading: url),
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                            frameCapacity: AVAudioFrameCount(file.length)),
              (try? file.read(into: buffer)) != nil,
              let channel = buffer.floatChannelData?[0] else { return nil }
        let samples = Array(UnsafeBufferPointer(start: channel, count: Int(buffer.frameLength)))
        return (samples, file.processingFormat.sampleRate)
    }

    // MARK: - Formants

    /// F1 and F2 for every voiced 25 ms frame (10 ms apart).
    static func formantTrack(_ samples: [Float], sampleRate: Double) -> [(Double, Double)] {
        let frameLength = Int(sampleRate * 0.025)
        let hop = Int(sampleRate * 0.010)
        guard samples.count > frameLength, frameLength > 0, hop > 0 else { return [] }

        // Pre-emphasis lifts the higher formants so linear prediction sees them.
        var emphasized = [Float](repeating: 0, count: samples.count)
        emphasized[0] = samples[0]
        for i in 1..<samples.count { emphasized[i] = samples[i] - 0.97 * samples[i - 1] }

        var window = [Float](repeating: 0, count: frameLength)
        vDSP_hamm_window(&window, vDSP_Length(frameLength), 0)

        // Loudness of each frame, to keep only the voiced ones.
        let starts = Array(stride(from: 0, to: samples.count - frameLength, by: hop))
        let loudness: [Float] = starts.map { start in
            var rms: Float = 0
            samples.withUnsafeBufferPointer {
                vDSP_rmsqv($0.baseAddress! + start, 1, &rms, vDSP_Length(frameLength))
            }
            return rms
        }
        let loudest = loudness.max() ?? 0
        let voicedFloor = max(loudest * 0.2, 0.004)
        let order = 2 + Int(sampleRate / 1000)

        var track: [(Double, Double)] = []
        var frame = [Float](repeating: 0, count: frameLength)
        for (index, start) in starts.enumerated() where loudness[index] >= voicedFloor {
            guard zeroCrossingRate(samples, start: start, length: frameLength) < 0.3 else { continue }
            emphasized.withUnsafeBufferPointer {
                vDSP_vmul($0.baseAddress! + start, 1, window, 1, &frame, 1, vDSP_Length(frameLength))
            }
            guard let lpc = linearPrediction(frame, order: order),
                  let formants = formants(lpc: lpc, sampleRate: sampleRate) else { continue }
            track.append(formants)
        }
        return track
    }

    /// Voiced sounds cross zero rarely; hissy ones ("sss", breath) often.
    static func zeroCrossingRate(_ samples: [Float], start: Int, length: Int) -> Double {
        var crossings = 0
        for i in (start + 1)..<(start + length) where (samples[i] >= 0) != (samples[i - 1] >= 0) {
            crossings += 1
        }
        return Double(crossings) / Double(length)
    }

    /// Linear prediction coefficients (autocorrelation + Levinson–Durbin).
    static func linearPrediction(_ frame: [Float], order: Int) -> [Double]? {
        var r = [Double](repeating: 0, count: order + 1)
        frame.withUnsafeBufferPointer { p in
            for lag in 0...order {
                var sum: Float = 0
                vDSP_dotpr(p.baseAddress!, 1, p.baseAddress! + lag, 1, &sum, vDSP_Length(frame.count - lag))
                r[lag] = Double(sum)
            }
        }
        guard r[0] > 1e-9 else { return nil }
        r[0] *= 1.0001          // tiny noise floor keeps the solution stable

        var a = [Double](repeating: 0, count: order + 1)
        a[0] = 1
        var error = r[0]
        for i in 1...order {
            var acc = r[i]
            for j in 1..<i { acc += a[j] * r[i - j] }
            let k = -acc / error
            var next = a
            for j in 1..<i { next[j] = a[j] + k * a[i - j] }
            next[i] = k
            a = next
            error *= (1 - k * k)
            guard error > 0 else { return nil }
        }
        return a
    }

    /// The first two peaks of the vocal-tract envelope, between 200 and 4000 Hz.
    static func formants(lpc a: [Double], sampleRate: Double) -> (Double, Double)? {
        let step = 10.0
        let frequencies = Array(stride(from: 150.0, through: min(4200, sampleRate / 2 - 100), by: step))
        let envelope: [Double] = frequencies.map { f in
            let w = 2 * Double.pi * f / sampleRate
            var re = 0.0, im = 0.0
            for (k, coefficient) in a.enumerated() {
                re += coefficient * cos(w * Double(k))
                im -= coefficient * sin(w * Double(k))
            }
            return 1 / max(re * re + im * im, 1e-12)
        }
        var peaks: [Double] = []
        for i in 1..<(envelope.count - 1)
        where envelope[i] > envelope[i - 1] && envelope[i] >= envelope[i + 1] && frequencies[i] >= 200 {
            if let last = peaks.last, frequencies[i] - last < 200 { continue }
            peaks.append(frequencies[i])
            if peaks.count == 2 { break }
        }
        guard peaks.count == 2, peaks[0] < 1300 else { return nil }
        return (peaks[0], peaks[1])
    }
}
