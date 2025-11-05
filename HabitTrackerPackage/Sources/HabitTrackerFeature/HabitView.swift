import SwiftUI

public struct HabitView: View {
    @Environment(HabitStore.self) private var habitStore
    @State private var showingNewHabit = false
    @State private var showInactive = false
    
    public init() {}
    
    private var displayedHabits: [Habit] {
        if showInactive {
            return habitStore.habits
        } else {
            return habitStore.activeHabits
        }
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if displayedHabits.isEmpty {
                    ContentUnavailableView(
                        showInactive ? "No Habits" : "No Active Habits",
                        systemImage: "list.bullet",
                        description: Text(showInactive ? "Tap the + button to create your first habit" : "Tap the + button to create your first habit")
                    )
                } else {
                    List {
                        if !habitStore.activeHabits.isEmpty {
                            Section("Active Habits") {
                                ForEach(habitStore.activeHabits) { habit in
                                    NavigationLink(value: habit) {
                                        HabitRowView(habitStore: habitStore, habitId: habit.id)
                                    }
                                }
                            }
                        }
                        
                        if showInactive && !habitStore.inactiveHabits.isEmpty {
                            Section("Inactive Habits") {
                                ForEach(habitStore.inactiveHabits) { habit in
                                    NavigationLink(value: habit) {
                                        HabitRowView(habitStore: habitStore, habitId: habit.id)
                                    }
                                }
                            }
                        }
                    }
                    .navigationDestination(for: Habit.self) { habit in
                        HabitDetailView(habitStore: habitStore, habit: habit)
                    }
                    .safeAreaInset(edge: .bottom) {
                        Toggle("Show Inactive Habits", isOn: $showInactive)
                            .padding()
                            .background(.regularMaterial)
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewHabit = true
                    } label: {
                        Label("New Habit", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewHabit) {
                NewHabitView { habit in
                    habitStore.add(habit)
                }
            }
        }
    }
}

