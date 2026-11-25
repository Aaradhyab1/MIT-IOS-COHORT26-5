import Foundation

/// "Good morning / afternoon / evening" from the device's local time.
/// Figma design note: 5:00–11:59 morning, 12:00–16:59 afternoon, 17:00–4:59 evening.
enum Greeting {
    static func text(for date: Date, calendar: Calendar = .current) -> String {
        switch calendar.component(.hour, from: date) {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
    }
}
