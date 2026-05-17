import UIKit

struct UserContentConfiguration: UIContentConfiguration {
    var user: User
    var onToggleFollow: (() -> Void)?

    func makeContentView() -> UIView & UIContentView {
        UserContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        self
    }
}
