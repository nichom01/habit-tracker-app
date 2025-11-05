import SwiftUI

public struct EditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var habit: Habit
    
    @State private var name: String
    @State private var description: String
    @State private var frequency: HabitFrequency
    @State private var effectiveFrom: Date?
    @State private var effectiveTo: Date?
    @State private var hasStartDate: Bool
    @State private var hasEndDate: Bool
    
    private let onSave: () -> Void
    
    public init(habit: Binding<Habit>, onSave: @escaping () -> Void) {
        self._habit = habit
        self.onSave = onSave
        
        // Initialize state from habit
        _name = State(initialValue: habit.wrappedValue.name)
        _description = State(initialValue: habit.wrappedValue.description)
        _frequency = State(initialValue: habit.wrappedValue.frequency)
        _effectiveFrom = State(initialValue: habit.wrappedValue.effectiveFrom)
        _effectiveTo = State(initialValue: habit.wrappedValue.effectiveTo)
        _hasStartDate = State(initialValue: habit.wrappedValue.effectiveFrom != nil)
        _hasEndDate = State(initialValue: habit.wrappedValue.effectiveTo != nil)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Habit Information") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Frequency") {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                }
                
                Section("Effective Dates") {
                    Toggle("Set Start Date", isOn: $hasStartDate)
                    if hasStartDate {
                        DatePicker("Effective From", selection: Binding(
                            get: { effectiveFrom ?? Date() },
                            set: { effectiveFrom = $0 }
                        ), displayedComponents: .date)
                    }
                    
                    Toggle("Set End Date", isOn: $hasEndDate)
                    if hasEndDate {
                        DatePicker("Effective To", selection: Binding(
                            get: { effectiveTo ?? Date() },
                            set: { effectiveTo = $0 }
                        ), displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveHabit() {
        habit.name = name
        habit.description = description
        habit.frequency = frequency
        habit.effectiveFrom = hasStartDate ? effectiveFrom : nil
        habit.effectiveTo = hasEndDate ? effectiveTo : nil
        habit.updatedAt = Date()
        onSave()
        dismiss()
    }
}

