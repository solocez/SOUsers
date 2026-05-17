import UIKit

final class UsersCoordinator: Coordinator {
    var children: [Coordinator] = []
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = UsersListViewModel()
        viewModel.onUserSelected = { [weak self] user in
            self?.showUserDetail(user)
        }
        let vc = UsersListView(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - Private

    private func showUserDetail(_ user: User) {
        let viewModel = UserDetailsViewModel(user: user)
        let vc = UserDetailsView(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
