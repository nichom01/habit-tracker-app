import Foundation

/// Handles persistence of habits to local storage
public final class HabitPersistence {
    private let fileName = "habits.json"
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    public init() {}
    
    /// Loads habits from local storage
    public func loadHabits() -> [Habit] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let habits = try decoder.decode([Habit].self, from: data)
            return habits
        } catch {
            print("Error loading habits: \(error)")
            return []
        }
    }
    
    /// Saves habits to local storage
    public func saveHabits(_ habits: [Habit]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            let data = try encoder.encode(habits)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Error saving habits: \(error)")
        }
    }
}

