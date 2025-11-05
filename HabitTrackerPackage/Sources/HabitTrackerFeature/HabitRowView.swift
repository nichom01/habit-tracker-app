import SwiftUI

public struct HabitRowView: View {
    @Bindable var habitStore: HabitStore
    let habitId: UUID
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private var habit: Habit? {
        habitStore.habits.first(where: { $0.id == habitId })
    }
    
    public init(habitStore: HabitStore, habitId: UUID) {
        self.habitStore = habitStore
        self.habitId = habitId
    }
    
    private func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    public var body: some View {
        if let habit = habit {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HStack(spacing: 6) {
                        Text(habit.name)
                            .font(.headline)
                        
                        if !habit.isCurrentlyEffective {
                            Label("Inactive", systemImage: "pause.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    Text(habit.frequency.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
                
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label("\(habit.totalCompletions)", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let mostRecent = habit.mostRecentCompletion {
                        Text("Last: \(formatDate(mostRecent.timestamp))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

