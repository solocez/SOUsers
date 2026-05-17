import SwiftUI  // For Preview Purely
import UIKit

final class UsersListView: UIViewController {
    @Dependency(\.appState) private var appState

    private let viewModel: UsersListViewModel

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemBackground
        label.text = "Stack Overflow Users:"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private static let cellReuseIdentifier = "UserCellId"

    init(viewModel: UsersListViewModel) {
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

        setupSubviews()
        setupTableView()
        observeViewModel()

        viewModel.loadUsers()
    }

    // MARK: - Private

    private func setupSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: 0
            ),
            titleLabel.centerXAnchor.constraint(
                equalTo: safeArea.centerXAnchor
            ),

            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            tableView.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Self.cellReuseIdentifier
        )
    }

    private func observeViewModel() {
        withObservationTracking { [weak self] in
            guard let self else { return }
            _ = self.viewModel.state
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                self?.render()
                self?.observeViewModel()
            }
        }
    }

    private func render() {
        switch viewModel.state {
        case .idle, .inProgress, .ready:
            contentUnavailableConfiguration = nil
            tableView.reloadData()

        case .error:
            setupContentUnavailable()
        }
    }

    private func setupContentUnavailable() {
        var config = UIContentUnavailableConfiguration.empty()
        config.text = "No data"
        config.secondaryText = "Check your connection..."
        config.image = UIImage(systemName: "wifi.slash")
        contentUnavailableConfiguration = config
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate

extension UsersListView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        appState.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.cellReuseIdentifier,
            for: indexPath
        )

        guard let user = try? appState.getUser(at: indexPath.row) else {
            return mapUserToCell(dataUnavailableUser, to: cell, at: indexPath)
        }
        return mapUserToCell(user, to: cell, at: indexPath)
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectUser(userIdx: indexPath.row)
    }

    // MARK: - Private

    private func mapUserToCell(
        _ user: User,
        to cell: UITableViewCell,
        at indexPath: IndexPath
    )
        -> UITableViewCell
    {
        var config = UserContentConfiguration(user: user)
        config.onToggleFollow = { [weak viewModel, weak tableView] in
            Task {
                await viewModel?.toggleFollow(user: user)
                tableView?.reloadRows(at: [indexPath], with: .none)
            }
        }
        cell.contentConfiguration = config
        return cell
    }
}

// Just for Preview to keep coordinator alive.
// To be capable navigating - when click on a User row.
private enum UsersListPreviewBox {
    static var coordinator: UsersCoordinator?
}

#Preview("Non Empty") {
    setOverrides {
        $0.appState = AppStateKey.testValue
        $0.apiClient = .testValue
    }

    let nav = UINavigationController()
    let coord = UsersCoordinator(navigationController: nav)
    UsersListPreviewBox.coordinator = coord
    coord.start()
    return nav
}

#Preview("Empty") {
    clearOverrides()
    setOverrides {
        $0.apiClient = .noConnectionValue
    }

    let nav = UINavigationController()
    let coord = UsersCoordinator(navigationController: nav)
    UsersListPreviewBox.coordinator = coord
    coord.start()
    return nav
}
