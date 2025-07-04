import SwiftUI
import AVKit
import AppKit

struct ContentView: View {
    @State private var videoURL: URL?
    @State private var subtitleURL: URL?
    @State private var outputURL: URL?
    @State private var isMerging = false
    @State private var showPlayer = false
    @State private var mergeError: String?

    var body: some View {
        VStack(spacing: 12) {
            GroupBox(label: Text("1) Video Seç (.mp4)")) {
                HStack {
                    Button(action: { videoURL = openPanel(allowed: ["mp4", "mkv"]) }) {
                        Text("Gözat…")
                    }
                    Text(videoURL?.lastPathComponent ?? "Seçili dosya yok")
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(6)
            }

            GroupBox(label: Text("2) Altyazı Seç (.vtt)")) {
                HStack {
                    Button(action: { subtitleURL = openPanel(allowed: ["vtt"]) }) {
                        Text("Gözat…")
                    }
                    Text(subtitleURL?.lastPathComponent ?? "Seçili dosya yok")
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(6)
            }

            Button(action: merge) {
                if isMerging {
                    ProgressView()
                } else {
                    Text("3) Birleştir (ffmpeg)")
                }
            }
            .disabled(videoURL == nil || subtitleURL == nil || isMerging)
            .padding(.top, 8)

            if let out = outputURL {
                Button("4) Oynat") {
                    showPlayer = true
                }
                .padding(.top, 4)
            }

            if let error = mergeError {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .sheet(isPresented: $showPlayer) {
            if let url = outputURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(minWidth: 800, minHeight: 450)
            }
        }
    }

    // MARK: - Helper functions
    func openPanel(allowed: [String]) -> URL? {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = allowed
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        return panel.runModal() == .OK ? panel.url : nil
    }

    func merge() {
        guard let video = videoURL, let vtt = subtitleURL else { return }
        isMerging = true
        mergeError = nil

        let ffmpegPath = Self.findFFmpeg()

        let out = video.deletingLastPathComponent().appendingPathComponent(video.deletingPathExtension().lastPathComponent + "_tr.mp4")
        outputURL = out

        DispatchQueue.global(qos: .userInitiated).async {
            guard FileManager.default.fileExists(atPath: ffmpegPath) else {
                DispatchQueue.main.async {
                    isMerging = false
                    mergeError = "ffmpeg bulunamadı (\(ffmpegPath)). Lütfen Homebrew ile kurun: brew install ffmpeg"
                }
                return
            }

            let process = Process()
            process.launchPath = ffmpegPath
            process.arguments = ["-i", video.path,
                                 "-i", vtt.path,
                                 "-c", "copy", "-c:s", "mov_text",
                                 "-metadata:s:s:0", "language=tur",
                                 out.path]

            process.standardError = Pipe()
            process.launch()
            process.waitUntilExit()

            DispatchQueue.main.async {
                isMerging = false
                if process.terminationStatus == 0 {
                    mergeError = nil
                } else {
                    if let errData = (process.standardError as? Pipe)?.fileHandleForReading.availableData,
                       let errStr = String(data: errData, encoding: .utf8) {
                        mergeError = "Birleştirme hatası: \n" + errStr
                    } else {
                        mergeError = "Birleştirme sırasında hata oluştu. Kod: \(process.terminationStatus)"
                    }
                }
            }
        }
    }

    nonisolated static func findFFmpeg() -> String {
        let paths = ["/opt/homebrew/bin/ffmpeg",
                      "/usr/local/bin/ffmpeg",
                      "/usr/bin/ffmpeg"]
        for p in paths where FileManager.default.fileExists(atPath: p) {
            return p
        }
        return paths[0]
    }
} 