import Foundation
import Observation

/// Service for managing habits
@Observable
@MainActor
public final class HabitStore {
    private let persistence = HabitPersistence()
    private var isInitializing = false
    
    /// All habits
    public var habits: [Habit] = [] {
        didSet {
            if !isInitializing {
                saveHabits()
            }
        }
    }
    
    public init(habits: [Habit]? = nil) {
        isInitializing = true
        if let habits = habits {
            self.habits = habits
        } else {
            self.habits = persistence.loadHabits()
        }
        isInitializing = false
    }
    
    private func saveHabits() {
        persistence.saveHabits(habits)
    }
    
    /// Returns only active habits (currently effective)
    public var activeHabits: [Habit] {
        habits.filter { $0.isCurrentlyEffective }
    }
    
    /// Returns only inactive habits (not currently effective)
    public var inactiveHabits: [Habit] {
        habits.filter { !$0.isCurrentlyEffective }
    }
    
    /// Adds a new habit
    public func add(_ habit: Habit) {
        habits.append(habit)
    }
    
    /// Removes a habit by ID
    public func remove(habitId: UUID) {
        habits.removeAll { $0.id == habitId }
    }
    
    /// Updates an existing habit
    public func update(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else {
            return
        }
        habits[index] = habit
    }
    
    /// Records a completion for a habit
    public func recordCompletion(for habitId: UUID, notes: String? = nil) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else {
            return
        }
        var habit = habits[index]
        habit.recordCompletion(notes: notes)
        habits[index] = habit
    }
    
    /// Records a historic completion for a habit with a specific date
    public func recordHistoricCompletion(for habitId: UUID, date: Date, notes: String? = nil) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else {
            return
        }
        var habit = habits[index]
        habit.recordHistoricCompletion(date: date, notes: notes)
        habits[index] = habit
    }
    
    /// Archives a habit by setting its effectiveTo date to today
    public func archive(habitId: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else {
            return
        }
        var habit = habits[index]
        habit.effectiveTo = Date()
        habit.updatedAt = Date()
        habits[index] = habit
    }
    
    /// Unarchives a habit by clearing its effectiveTo date
    public func unarchive(habitId: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else {
            return
        }
        var habit = habits[index]
        habit.effectiveTo = nil
        habit.updatedAt = Date()
        habits[index] = habit
    }
}

