import Foundation

struct ResourceLink: Identifiable, Codable {
    var id: String { url }
    let title: String
    let subtitle: String
    let systemImage: String
    let url: String

    var linkURL: URL { URL(string: url)! }
}

enum ResourceLoader {
    static func loadResources(from filename: String = "resources") -> [ResourceLink] {
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: fileURL) else {
            print("⚠️ Could not find/read \(filename).json")
            return []
        }
        do {
            return try JSONDecoder().decode([ResourceLink].self, from: data)
        } catch {
            print("⚠️ Decode error: \(error)")
            return []
        }
    }
}
