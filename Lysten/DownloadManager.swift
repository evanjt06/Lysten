import Foundation
import AVKit

final class DownloadManager: ObservableObject {
    @Published var isDownloading = false
    @Published var isDownloaded = false

    func downloadFile(url: String) {
        print("downloadFile")
        isDownloading = true

        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        let destinationUrl = docsUrl?.appendingPathComponent(url + ".mp3")
        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                print("File already exists")
                isDownloading = false
            } else {
                let urlRequest = URLRequest(url: URL(string: "https://s3.us-west-2.amazonaws.com/calc.masa.space/music/" + url + ".mp3")!)

                let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in

                    if let error = error {
                        print("Request error: ", error)
                        self.isDownloading = false
                        return
                    }

                    guard let response = response as? HTTPURLResponse else { return }

                    if response.statusCode == 200 {
                        guard let data = data else {
                            self.isDownloading = false
                            return
                        }
                        DispatchQueue.main.async {
                            do {
                                try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)

                                DispatchQueue.main.async {
                                    self.isDownloading = false
                                    self.isDownloaded = true
                                }
                            } catch let error {
                                print("Error decoding: ", error)
                                self.isDownloading = false
                            }
                        }
                    }
                }
                dataTask.resume()
            }
        }
    }

    func deleteFile(url: String) {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        let destinationUrl = docsUrl?.appendingPathComponent(url)
        if let destinationUrl = destinationUrl {
            guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
                print("File deleted successfully")
                isDownloaded = false
            } catch let error {
                print("Error while deleting video file: ", error)
            }
        }
    }

    func checkFileExists(url: String) {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        let destinationUrl = docsUrl?.appendingPathComponent(url)
        print(destinationUrl)
        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                print("79")
                isDownloaded = true
            } else {
                print("82")
                isDownloaded = false
            }
        } else {
            isDownloaded = false
        }
    }

    func getVideoFileAsset(url: String) -> AVPlayerItem? {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        let destinationUrl = docsUrl?.appendingPathComponent(url)
        if let destinationUrl = destinationUrl {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                let avAssest = AVAsset(url: destinationUrl)
                return AVPlayerItem(asset: avAssest)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
