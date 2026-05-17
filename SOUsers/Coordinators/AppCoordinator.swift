import UIKit

final class AppCoordinator: Coordinator {
    var children: [Coordinator] = []
    let navigationController: UINavigationController
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        let usersFlow = UsersCoordinator(
            navigationController: navigationController
        )
        add(child: usersFlow)
        usersFlow.start()
    }
}
