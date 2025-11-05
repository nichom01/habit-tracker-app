import SwiftUI

public struct NewHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var frequency: HabitFrequency = .daily
    @State private var effectiveFrom: Date?
    @State private var effectiveTo: Date?
    @State private var hasStartDate: Bool = false
    @State private var hasEndDate: Bool = false
    
    private let onSave: (Habit) -> Void
    
    public init(onSave: @escaping (Habit) -> Void) {
        self.onSave = onSave
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
            .navigationTitle("New Habit")
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
        let habit = Habit(
            name: name,
            description: description,
            frequency: frequency,
            effectiveFrom: hasStartDate ? effectiveFrom : nil,
            effectiveTo: hasEndDate ? effectiveTo : nil
        )
        onSave(habit)
        dismiss()
    }
}

