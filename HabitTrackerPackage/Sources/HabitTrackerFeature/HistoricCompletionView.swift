import SwiftUI

public struct HistoricCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var habitStore: HabitStore
    
    @State private var selectedHabitId: UUID?
    @State private var selectedDate: Date = Date()
    @State private var notes: String = ""
    
    private let preSelectedHabitId: UUID?
    
    public init(habitStore: HabitStore, preSelectedHabitId: UUID? = nil) {
        self.habitStore = habitStore
        self.preSelectedHabitId = preSelectedHabitId
    }
    
    private var selectedHabit: Habit? {
        guard let habitId = selectedHabitId else { return nil }
        return habitStore.habits.first(where: { $0.id == habitId })
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Select Habit") {
                    Picker("Habit", selection: $selectedHabitId) {
                        Text("Select a habit").tag(nil as UUID?)
                        ForEach(habitStore.activeHabits) { habit in
                            Text(habit.name).tag(habit.id as UUID?)
                        }
                    }
                }
                .onAppear {
                    if let preSelectedId = preSelectedHabitId {
                        selectedHabitId = preSelectedId
                    }
                }
                
                if selectedHabit != nil {
                    Section("Completion Date") {
                        DatePicker("Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Section("Notes") {
                        TextField("Optional notes", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle("Add Historic Completion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCompletion()
                    }
                    .disabled(selectedHabitId == nil)
                }
            }
        }
    }
    
    private func saveCompletion() {
        guard let habitId = selectedHabitId else { return }
        habitStore.recordHistoricCompletion(for: habitId, date: selectedDate, notes: notes.isEmpty ? nil : notes)
        dismiss()
    }
}

