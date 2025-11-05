import SwiftUI

public struct ContentView: View {
    @State private var habitStore = HabitStore()
    
    public init() {}
    
    public var body: some View {
        TabView {
            DashboardView()
                .environment(habitStore)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            HabitView()
                .environment(habitStore)
                .tabItem {
                    Label("Habit", systemImage: "list.bullet")
                }
        }
    }
}
