import UIKit

class BaseViewController: UIViewController {
    private var viewModel: BaseViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
