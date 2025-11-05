import SwiftUI

public struct ContributionsGraphView: View {
    let habit: Habit
    let days: Int
    
    @State private var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let dayWidth: CGFloat = 11
    private let daySpacing: CGFloat = 3
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    public init(habit: Habit, days: Int = 90) {
        self.habit = habit
        self.days = days
    }
    
    private var endDate: Date {
        Date()
    }
    
    private var startDate: Date {
        calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
    }
    
    private var weeks: [[Date]] {
        var weeks: [[Date]] = []
        var week: [Date] = []
        var currentDate = startDate
        
        // Find the first Monday on or before startDate
        let startWeekday = calendar.component(.weekday, from: startDate)
        let daysToMonday = (startWeekday + 5) % 7 // Convert to Monday=0
        if daysToMonday > 0 {
            currentDate = calendar.date(byAdding: .day, value: -daysToMonday, to: startDate) ?? startDate
        }
        
        while currentDate <= endDate {
            week.append(currentDate)
            if week.count == 7 {
                weeks.append(week)
                week = []
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        if !week.isEmpty {
            weeks.append(week)
        }
        return weeks
    }
    
    private func completionsForDate(_ date: Date) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        return habit.audit.filter { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }.count
    }
    
    private func completionEntriesForDate(_ date: Date) -> [HabitAuditEntry] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        return habit.audit.filter { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    private func formatSelectedDate(_ date: Date) -> String {
        let entries = completionEntriesForDate(date)
        if entries.count == 1 {
            return dateFormatter.string(from: entries[0].timestamp)
        } else if entries.count > 1 {
            return entries.map { dateFormatter.string(from: $0.timestamp) }.joined(separator: ", ")
        }
        return dateFormatter.string(from: date)
    }
    
    private func colorForCompletions(_ count: Int) -> Color {
        switch count {
        case 0:
            return Color.secondary.opacity(0.15)
        case 1:
            return Color.green.opacity(0.4)
        case 2:
            return Color.green.opacity(0.6)
        case 3:
            return Color.green.opacity(0.8)
        default:
            return Color.green
        }
    }
    
    private var monthLabels: [(month: String, weekIndex: Int)] {
        var labels: [(month: String, weekIndex: Int)] = []
        var lastMonth = -1
        
        for (weekIndex, week) in weeks.enumerated() {
            guard let firstDay = week.first else { continue }
            let month = calendar.component(.month, from: firstDay)
            if month != lastMonth {
                let monthSymbol = calendar.shortMonthSymbols[month - 1]
                let firstLetter = String(monthSymbol.prefix(1))
                labels.append((month: firstLetter, weekIndex: weekIndex))
                lastMonth = month
            }
        }
        
        return labels
    }
    
    private var totalContributions: Int {
        habit.audit.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }.count
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Spacer()
                Text("\(totalContributions) completions in the last 3 months")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(.horizontal)
            
            // Graph
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    // Month labels
                    HStack(spacing: 0) {
                        Text("")
                            .frame(width: 30)
                        
                        HStack(spacing: daySpacing) {
                            ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                                let isFirstWeekOfMonth = monthLabels.contains { $0.weekIndex == weekIndex }
                                
                                if isFirstWeekOfMonth, let label = monthLabels.first(where: { $0.weekIndex == weekIndex }) {
                                    Text(label.month)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .frame(width: dayWidth, alignment: .leading)
                                } else {
                                    Text("")
                                        .frame(width: dayWidth)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Grid
                    HStack(alignment: .top, spacing: 0) {
                        // Day of week labels
                        VStack(alignment: .trailing, spacing: dayWidth + daySpacing) {
                            Text("Mon")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .trailing)
                            Text("Wed")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .trailing)
                            Text("Fri")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .trailing)
                        }
                        
                        // Contribution squares by week
                        HStack(alignment: .top, spacing: daySpacing) {
                            ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                                VStack(spacing: daySpacing) {
                                    ForEach(Array(week.enumerated()), id: \.offset) { dayIndex, date in
                                        let completions = completionsForDate(date)
                                        let isSelected: Bool = {
                                            guard let selected = selectedDate else { return false }
                                            return calendar.isDate(date, inSameDayAs: selected)
                                        }()
                                        
                                        Button {
                                            if completions > 0 {
                                                selectedDate = date
                                            } else {
                                                selectedDate = nil
                                            }
                                        } label: {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(colorForCompletions(completions))
                                                .frame(width: dayWidth, height: dayWidth)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
            
            // Selected date label
            HStack {
                Spacer()
                if let selectedDate = selectedDate, completionsForDate(selectedDate) > 0 {
                    Text(formatSelectedDate(selectedDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("")
                        .font(.caption)
                        .frame(height: 20)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
        .padding(.vertical)
    }
}

