import SwiftUI  // For Preview Purely
import UIKit

final class UserDetailsView: UIViewController {

    private let viewModel: UserDetailsViewModel

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let avatarImageView: URLImageView = {
        let imageView = URLImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.backgroundColor = .secondarySystemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let reputationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var followButton = FollowButton(onToggleFollow: {
        [weak self] in
        Task {
            await self?.viewModel.toggleFollow()
        }
    })

    init(viewModel: UserDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "User Details:"

        setupSubviews()
        observeViewModel()
        viewModel.loadUser()
    }

    // MARK: - Private

    private func setupSubviews() {
        view.addSubview(contentStack)

        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.setContentHuggingPriority(.required, for: .horizontal)

        contentStack.addArrangedSubview(avatarImageView)
        contentStack.addArrangedSubview(nameLabel)
        contentStack.addArrangedSubview(reputationLabel)
        contentStack.addArrangedSubview(followButton)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: 24
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -16
            ),

            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
        ])
    }

    private func observeViewModel() {
        withObservationTracking { [weak self] in
            guard let self else { return }
            _ = self.viewModel.user
            _ = self.viewModel.state
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                self?.render()
                self?.observeViewModel()
            }
        }
    }

    private func render() {
        let user = viewModel.user

        nameLabel.text = user.name
        reputationLabel.text = "Reputation: \(user.reputation)"
        followButton.isFollowed = user.isFollowed

        guard let url = user.profileImageURL else { return }
        avatarImageView.load(url: url)
    }
}

#Preview {
    UINavigationController(
        rootViewController: UserDetailsView(
            viewModel: UserDetailsViewModel(user: mockUser1)
        )
    )
}
