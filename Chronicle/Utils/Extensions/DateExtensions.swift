import SwiftUI

extension Date {
    var asISOString: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }

    var asHourMinuteString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    var asDayMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMM"
        return formatter.string(from: self)
    }
}
