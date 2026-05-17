import SwiftUI  // For Preview Purely
import UIKit

final class URLImageView: UIImageView {
    private var task: Task<Void, Never>?

    init() {
        super.init(frame: .zero)
    }

    init(
        url: URL,
        placeholder: UIImage = UIImage(systemName: "person.crop.circle")!
    ) {
        super.init(frame: .zero)
        self.image = placeholder
        load(url: url, placeholder: placeholder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        task?.cancel()
    }

    func load(
        url: URL,
        placeholder: UIImage = UIImage(systemName: "person.crop.circle")!
    ) {
        task?.cancel()
        image = placeholder

        task = Task { [weak self] in
            guard let self else { return }
            do {
                let (data, response) = try await URLSession.shared.data(
                    from: url
                )
                guard
                    let response = response as? HTTPURLResponse,
                    200..<300 ~= response.statusCode
                else {
                    return
                }
                // It was good idea to put the image to an Image Cache.
                // But, not with this task.
                guard let downloadedImage = UIImage(data: data) else { return }
                guard !Task.isCancelled else { return }

                await MainActor.run { [weak self] in
                    self?.image = downloadedImage
                }
            } catch {
                // left non processed for simplicity
            }
        }
    }
}

#Preview {
    URLImageView(
        url: URL(
            string:
                "https://www.gravatar.com/avatar/6d8ebb117e8d83d74ea95fbdd0f87e13?s=256&d=identicon&r=PG"
        )!
    )
}
