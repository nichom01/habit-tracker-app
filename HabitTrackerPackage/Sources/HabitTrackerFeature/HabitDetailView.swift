import SwiftUI

public struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var habitStore: HabitStore
    let habit: Habit
    
    @State private var showingEditHabit = false
    @State private var showingArchiveConfirmation = false
    @State private var showingHistoricCompletion = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    public init(habitStore: HabitStore, habit: Habit) {
        self.habitStore = habitStore
        self.habit = habit
    }
    
    private func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    private var habitBinding: Binding<Habit> {
        Binding(
            get: { habitStore.habits.first(where: { $0.id == habit.id }) ?? habit },
            set: { habitStore.update($0) }
        )
    }
    
    private var currentHabit: Habit {
        habitStore.habits.first(where: { $0.id == habit.id }) ?? habit
    }
    
    private var isDoneToday: Bool {
        currentHabit.isDoneToday
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                // Header Section
                VStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .center, spacing: 8) {
                        Text(currentHabit.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        if !currentHabit.description.isEmpty {
                            Text(currentHabit.description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        if !currentHabit.isCurrentlyEffective {
                            Label("Inactive", systemImage: "pause.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Stats
                    HStack(spacing: 20) {
                        VStack(alignment: .center) {
                            Text("Total Completions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(currentHabit.totalCompletions)")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .center) {
                            Text("Frequency")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(currentHabit.frequency.displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        if let mostRecent = currentHabit.mostRecentCompletion {
                            VStack(alignment: .center) {
                                Text("Last Done")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(formatDate(mostRecent.timestamp))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                // Primary Action: Mark as Done for Today
                VStack(spacing: 16) {
                    if isDoneToday {
                        Button {
                            // Already done today - could show message or remove today's entry
                        } label: {
                            Label("Completed Today", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .foregroundStyle(.green)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(true)
                    } else {
                        Button {
                            habitStore.recordCompletion(for: currentHabit.id)
                        } label: {
                            Label("Mark as Done for Today", systemImage: "checkmark.circle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                
                // Contributions Graph
                if !currentHabit.audit.isEmpty {
                    ContributionsGraphView(habit: currentHabit)
                        .padding(.vertical)
                }
                
                Spacer(minLength: 100) // Space for bottom buttons
            }
        }
        .navigationTitle(currentHabit.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            // Secondary Actions at Bottom
            VStack(spacing: 12) {
                Button {
                    showingHistoricCompletion = true
                } label: {
                    Label("Add Historic Completion", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                HStack(spacing: 12) {
                    Button {
                        showingEditHabit = true
                    } label: {
                        Label("Update", systemImage: "pencil")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(role: .destructive) {
                        showingArchiveConfirmation = true
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .foregroundStyle(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
        }
        .sheet(isPresented: $showingEditHabit) {
            EditHabitView(habit: habitBinding) {
                habitStore.update(habitBinding.wrappedValue)
            }
        }
        .sheet(isPresented: $showingHistoricCompletion) {
            HistoricCompletionView(habitStore: habitStore, preSelectedHabitId: currentHabit.id)
        }
        .confirmationDialog("Archive Habit", isPresented: $showingArchiveConfirmation, titleVisibility: .visible) {
            Button("Archive", role: .destructive) {
                habitStore.archive(habitId: currentHabit.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to archive this habit? You can unarchive it later.")
        }
    }
}

