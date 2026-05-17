import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    @Dependency(\.appState) var appState

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        let coordinator = AppCoordinator(window: window)
        self.window = window
        self.appCoordinator = coordinator

        coordinator.start()
    }
}
