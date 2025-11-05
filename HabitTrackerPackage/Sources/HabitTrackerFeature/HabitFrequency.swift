import Foundation

/// Represents how often a habit should be completed
public enum HabitFrequency: String, Codable, CaseIterable, Sendable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case custom = "Custom"
    
    /// Display name for the frequency
    public var displayName: String {
        rawValue
    }
    
    /// Description of what the frequency means
    public var description: String {
        switch self {
        case .daily:
            return "Complete this habit every day"
        case .weekly:
            return "Complete this habit once per week"
        case .monthly:
            return "Complete this habit once per month"
        case .custom:
            return "Custom frequency schedule"
        }
    }
}

