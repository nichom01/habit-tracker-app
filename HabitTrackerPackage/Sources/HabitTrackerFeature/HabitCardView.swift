import SwiftUI

public struct HabitCardView: View {
    let habit: Habit
    let onTap: () -> Void
    
    public init(habit: Habit, onTap: @escaping () -> Void) {
        self.habit = habit
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(habit.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
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
                
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(habit.totalCompletions)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if habit.currentStreak > 0 {
                            Text("\(habit.currentStreak)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                            Text("Day Streak")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if let daysSince = habit.daysSinceLastCompletion {
                            Text("\(daysSince)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.orange)
                            Text(daysSince == 1 ? "Day Ago" : "Days Ago")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("—")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            Text("No Completions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

