import Foundation

/// Represents a habit with tracking information
public struct Habit: Codable, Identifiable, Sendable {
    /// Unique identifier for this habit
    public let id: UUID
    
    /// Name of the habit
    public var name: String
    
    /// Description of what the habit entails
    public var description: String
    
    /// How often the habit should be completed
    public var frequency: HabitFrequency
    
    /// Audit log of all habit completions with timestamps
    public var audit: [HabitAuditEntry]
    
    /// Date when the habit was created
    public let createdAt: Date
    
    /// Date when the habit was last modified
    public var updatedAt: Date
    
    /// Optional start date when the habit becomes effective
    public var effectiveFrom: Date?
    
    /// Optional end date when the habit is no longer effective
    public var effectiveTo: Date?
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        frequency: HabitFrequency,
        audit: [HabitAuditEntry] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        effectiveFrom: Date? = nil,
        effectiveTo: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.frequency = frequency
        self.audit = audit
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.effectiveFrom = effectiveFrom
        self.effectiveTo = effectiveTo
    }
    
    /// Adds a new completion entry to the audit log
    public mutating func recordCompletion(notes: String? = nil) {
        let entry = HabitAuditEntry(timestamp: Date(), notes: notes)
        audit.append(entry)
        updatedAt = Date()
    }
    
    /// Returns the most recent completion, if any
    public var mostRecentCompletion: HabitAuditEntry? {
        audit.max(by: { $0.timestamp < $1.timestamp })
    }
    
    /// Returns the total number of completions
    public var totalCompletions: Int {
        audit.count
    }
    
    /// Checks if the habit is effective on a given date
    /// - Parameter date: The date to check (defaults to current date)
    /// - Returns: `true` if the habit is effective on the given date
    public func isEffective(on date: Date = Date()) -> Bool {
        // If effectiveFrom is set and date is before it, not effective yet
        if let effectiveFrom = effectiveFrom, date < effectiveFrom {
            return false
        }
        
        // If effectiveTo is set and date is after it, no longer effective
        if let effectiveTo = effectiveTo, date > effectiveTo {
            return false
        }
        
        return true
    }
    
    /// Returns whether the habit is currently effective
    public var isCurrentlyEffective: Bool {
        isEffective(on: Date())
    }
    
    /// Checks if the habit was completed today
    public var isDoneToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return audit.contains { entry in
            calendar.startOfDay(for: entry.timestamp) == today
        }
    }
    
    /// Calculates the current streak (consecutive days with completions)
    public var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // Check if done today, if not streak is 0
        let today = currentDate
        let hasToday = audit.contains { entry in
            calendar.startOfDay(for: entry.timestamp) == today
        }
        
        if !hasToday {
            return 0
        }
        
        streak = 1 // Today counts
        
        // Go back day by day
        while true {
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            
            let hasCompletion = audit.contains { entry in
                calendar.startOfDay(for: entry.timestamp) == previousDate
            }
            
            if hasCompletion {
                streak += 1
                currentDate = previousDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    /// Returns the number of days since the last completion, or nil if never completed
    public var daysSinceLastCompletion: Int? {
        guard let mostRecent = mostRecentCompletion else {
            return nil
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastCompletion = calendar.startOfDay(for: mostRecent.timestamp)
        
        guard let days = calendar.dateComponents([.day], from: lastCompletion, to: today).day else {
            return nil
        }
        
        return days
    }
}

extension Habit: Equatable {
    public static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id
    }
}

extension Habit: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

