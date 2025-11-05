import Foundation

/// Represents a single completion record for a habit
public struct HabitAuditEntry: Codable, Identifiable, Sendable {
    /// Unique identifier for this audit entry
    public let id: UUID
    
    /// Timestamp when the habit was completed
    public let timestamp: Date
    
    /// Optional notes about this completion
    public var notes: String?
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.notes = notes
    }
}

extension HabitAuditEntry: Equatable {
    public static func == (lhs: HabitAuditEntry, rhs: HabitAuditEntry) -> Bool {
        lhs.id == rhs.id
    }
}

