import SwiftUI  // For Preview Purely
import UIKit

final class FollowButton: UIButton {
    var isFollowed = false {
        didSet {
            updateFollowingState()
        }
    }

    private var onToggleFollow: (() -> Void)?

    init(onToggleFollow: (() -> Void)?) {
        self.onToggleFollow = onToggleFollow
        super.init(frame: .zero)
        configure()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    // MARK: - Private

    private func configure() {
        addAction(
            UIAction { [weak self] _ in
                self?.onToggleFollow?()
            },
            for: .touchUpInside
        )
        configuration = .plain()
        updateFollowingState()
    }

    private func updateFollowingState() {
        configuration?.image = UIImage(
            systemName: isFollowed
                ? "checkmark.circle.fill" : "checkmark.circle"
        )
        configuration?.baseForegroundColor =
            isFollowed ? .systemBlue : .secondaryLabel
    }
}

#Preview {
    let followed = FollowButton()
    followed.isFollowed = true
    let buttons = UIStackView(
        arrangedSubviews: [
            FollowButton(),
            followed,
        ]
    )
    buttons.axis = .vertical
    return buttons
}
