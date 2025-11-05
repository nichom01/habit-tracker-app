import SwiftUI

public struct ContentView: View {
    public init() {}
    
    public var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            
            HabitView()
                .tabItem {
                    Label("Habit", systemImage: "list.bullet")
                }
            
            UpdateView()
                .tabItem {
                    Label("Update", systemImage: "plus.circle.fill")
                }
        }
    }
}
