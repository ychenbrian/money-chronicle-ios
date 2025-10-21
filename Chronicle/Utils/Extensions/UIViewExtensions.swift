import UIKit

extension UIView {
    func roundedCorner(cornerRadiusValue: CGFloat = 8) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadiusValue
    }
}

extension CALayer {
    func applyCornerRadiusShadow(
        color: UIColor = .lightGray,
        alpha: Float = 0.3,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 8,
        spread: CGFloat = 0,
        cornerRadiusValue: CGFloat = 8
    ) {
        cornerRadius = cornerRadiusValue
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: 0)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
