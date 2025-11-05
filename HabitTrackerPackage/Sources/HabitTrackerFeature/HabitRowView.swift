import SwiftUI

public struct HabitRowView: View {
    let habit: Habit
    
    public init(habit: Habit) {
        self.habit = habit
    }
    
    public var body: some View {
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
                    Text("Last: \(mostRecent.timestamp, style: .date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

