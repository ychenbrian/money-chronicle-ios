import UIKit

enum AppColor: String, CaseIterable {
    // MARK: - Text Colors

    case primaryTextColor
    case secondaryTextColor

    // MARK: - Background Colors

    case primaryBackgroundColor
    case secondaryBackgroundColor
    case blueBackgroundColor
}

extension UIColor {
    static func appColor(_ color: AppColor) -> UIColor {
        guard let uiColor = UIColor(named: color.rawValue) else {
            fatalError("Color \(color.rawValue) not found in asset catalog")
        }
        return uiColor
    }
}
