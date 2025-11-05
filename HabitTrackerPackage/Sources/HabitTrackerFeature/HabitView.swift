import SwiftUI

public struct HabitView: View {
    @State private var habitStore = HabitStore()
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
                                    HabitRowView(habit: habit)
                                }
                            }
                        }
                        
                        if showInactive && !habitStore.inactiveHabits.isEmpty {
                            Section("Inactive Habits") {
                                ForEach(habitStore.inactiveHabits) { habit in
                                    HabitRowView(habit: habit)
                                }
                            }
                        }
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
                
                ToolbarItem(placement: .automatic) {
                    Toggle("Show Inactive", isOn: $showInactive)
                        .labelsHidden()
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

