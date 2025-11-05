import SwiftUI

public struct DashboardView: View {
    @Environment(HabitStore.self) private var habitStore
    @State private var selectedHabit: Habit?
    
    public init() {}
    
    private var displayedHabits: [Habit] {
        Array(habitStore.activeHabits.prefix(6))
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                if displayedHabits.isEmpty {
                    ContentUnavailableView(
                        "No Active Habits",
                        systemImage: "chart.bar",
                        description: Text("Create habits to see them on your dashboard")
                    )
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(displayedHabits) { habit in
                            HabitCardView(habit: habit) {
                                selectedHabit = habit
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
            .sheet(item: $selectedHabit) { habit in
                NavigationStack {
                    HabitDetailView(habitStore: habitStore, habit: habit)
                }
            }
        }
    }
}

