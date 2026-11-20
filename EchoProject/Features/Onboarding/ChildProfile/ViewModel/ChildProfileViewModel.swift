import Foundation
import Observation

/// "About your child": two optional dates that help pick the right practice.
/// Both can be left empty, and "Skip for now" saves nothing. No name is asked for.
@Observable
@MainActor
final class ChildProfileViewModel {
    enum DateField: String, Identifiable {
        case dateOfBirth
        case activationDate
        var id: String { rawValue }
    }

    private(set) var dateOfBirth: Date?
    private(set) var activationDate: Date?

    /// The field whose calendar sheet is open; nil when no sheet is showing.
    var editingField: DateField?
    /// The date selected in the open calendar, saved only when Done is tapped.
    var draftDate = Date()

    private let router: AppRouter
    private let profile: any ProfileRepository
    private let today: () -> Date

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()

    init(router: AppRouter, profile: any ProfileRepository, today: @escaping () -> Date = Date.init) {
        self.router = router
        self.profile = profile
        self.today = today
        let saved = profile.currentProfile()
        dateOfBirth = saved?.dateOfBirth
        activationDate = saved?.activationDate
    }

    // MARK: - Text for the View

    /// "11/19/2021", or nil while the field is empty (the View shows "mm/dd/yyyy").
    func text(for field: DateField) -> String? {
        date(for: field).map { Self.formatter.string(from: $0) }
    }

    /// Title of the calendar sheet.
    var editingTitle: String {
        switch editingField {
        case .dateOfBirth: "Date of birth"
        case .activationDate: "Activation date"
        case nil: ""
        }
    }

    /// Dates the open calendar allows: nothing in the future, and the activation
    /// date can't be before the date of birth.
    var draftRange: ClosedRange<Date> {
        let lowest = editingField == .activationDate ? (dateOfBirth ?? .distantPast) : .distantPast
        return lowest...today()
    }

    // MARK: - Actions

    func didTapField(_ field: DateField) {
        draftDate = date(for: field) ?? defaultDate(for: field)
        editingField = field
    }

    func didConfirmDate() {
        switch editingField {
        case .dateOfBirth:
            dateOfBirth = draftDate
            // An activation date before the new birth date can't be right; clear it.
            if let activation = activationDate, activation < draftDate {
                activationDate = nil
            }
        case .activationDate:
            activationDate = draftDate
        case nil:
            break
        }
        editingField = nil
    }

    func didClearDate() {
        switch editingField {
        case .dateOfBirth: dateOfBirth = nil
        case .activationDate: activationDate = nil
        case nil: break
        }
        editingField = nil
    }

    func didTapContinue() {
        let saved = profile.currentProfile()
        profile.save(ChildProfile(
            id: saved?.id ?? UUID(),
            name: nil,
            dateOfBirth: dateOfBirth,
            hearingDevice: saved?.hearingDevice,
            activationDate: activationDate,
            recommendedLevel: saved?.recommendedLevel ?? 1,
            onboardingCompleted: saved?.onboardingCompleted ?? false
        ))
        router.go(.choosePath)
    }

    func didTapSkip() {
        router.go(.choosePath)
    }

    // MARK: - Private

    private func date(for field: DateField) -> Date? {
        switch field {
        case .dateOfBirth: dateOfBirth
        case .activationDate: activationDate
        }
    }

    /// Where the calendar opens when the field is empty: three years ago for a
    /// birth date (closer to a typical child's age), today for an activation date.
    private func defaultDate(for field: DateField) -> Date {
        switch field {
        case .dateOfBirth: Calendar.current.date(byAdding: .year, value: -3, to: today()) ?? today()
        case .activationDate: today()
        }
    }
}
