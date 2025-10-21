@testable import Chronicle_Staging
import UIKit
import XCTest

class ResourceHelperTests: XCTestCase {
    func testColorAvailablity() {
        for color in AppColor.allCases {
            let colorInstance = UIColor.appColor(color)
            XCTAssertNotNil(colorInstance, "Color `\(color.rawValue)` should be available.")
        }
    }
}
