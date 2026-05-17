import UIKit

@MainActor
protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    var navigationController: UINavigationController { get }

    func start()
}

extension Coordinator {
    func add(child: Coordinator) { children.append(child) }
    func remove(child: Coordinator) { children.removeAll { $0 === child } }
}
