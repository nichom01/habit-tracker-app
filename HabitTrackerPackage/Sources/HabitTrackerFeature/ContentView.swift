import SwiftUI

public enum TabSelection: Int {
    case home = 0
    case habit = 1
}

public struct ContentView: View {
    @State private var habitStore = HabitStore()
    @State private var selectedTab: TabSelection
    
    public init(initialTab: TabSelection = .home) {
        _selectedTab = State(initialValue: initialTab)
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environment(habitStore)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(TabSelection.home)
            
            HabitView()
                .environment(habitStore)
                .tabItem {
                    Label("Habit", systemImage: "list.bullet")
                }
                .tag(TabSelection.habit)
        }
    }
}
