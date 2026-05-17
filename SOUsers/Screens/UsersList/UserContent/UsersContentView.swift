import UIKit

final class UserContentView: UIView, UIContentView {
    private let imageView = URLImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private lazy var followButton = FollowButton(onToggleFollow: {
        [weak self] in
        self?.onToggleFollow?()
    })

    private var onToggleFollow: (() -> Void)?

    var configuration: UIContentConfiguration {
        didSet {
            apply(configuration: configuration)
        }
    }

    init(configuration: UserContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupUI()
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Private

    private func setupUI() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.setContentHuggingPriority(.required, for: .horizontal)

        imageView.contentMode = .scaleAspectFill

        let labels = UIStackView(
            arrangedSubviews: [
                titleLabel,
                subtitleLabel,
            ]
        )
        labels.axis = .vertical
        labels.spacing = 4
        labels.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(labels)
        addSubview(followButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40),

            labels.leadingAnchor.constraint(
                equalTo: imageView.trailingAnchor,
                constant: 16
            ),
            labels.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            labels.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -12
            ),

            followButton.leadingAnchor.constraint(
                equalTo: labels.trailingAnchor,
                constant: 12
            ),
            followButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            followButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    private func apply(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? UserContentConfiguration
        else { return }

        titleLabel.text = configuration.user.name
        subtitleLabel.text = "Reputation: \(configuration.user.reputation)"

        onToggleFollow = configuration.onToggleFollow
        followButton.isFollowed = configuration.user.isFollowed

        guard let url = configuration.user.profileImageURL else { return }
        imageView.load(url: url)
    }
}
